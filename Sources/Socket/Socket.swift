import Dispatch
#if os(Linux)
	import Glibc
#else
	import Darwin
	import CoreFoundation
#endif

public enum SocketType {
    case server
    case client
}

public class Socket {
    public weak var delegate: SocketDelegate?
	public let fd: Int32
    
    private let workQueue: DispatchQueue
    private(set) var socketType: SocketType = .server
    
    private var readingSource: DispatchSourceRead?
    private var writingSource: DispatchSourceWrite?
    private var canWrite: Bool = false
    private var sendBuffer: [UInt8] = []
    
    private var isOpen: Bool      = false
    private var shouldClose: Bool = false
    private var isReading: Bool   = false
    private var isWriting: Bool   = false
	
	public init() {
		#if os(Linux)
			fd = Glibc.socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
		#else
			fd = Darwin.socket(AF_INET, SOCK_STREAM, 0)
		#endif
        workQueue = DispatchQueue(label: "workQueue.\(fd)")
	}
	
	private init(fd: Int32) {
		self.fd = fd
        workQueue = DispatchQueue(label: "workQueue.\(fd)")
        makeNonBlocking(fd: fd)
        
        readingSource = DispatchSource.makeReadSource(fileDescriptor: fd, queue: workQueue)
        readingSource?.setEventHandler() {
            self.readAvailableData()
        }
        readingSource?.setCancelHandler() {
            self.readingSource = nil
        }
        readingSource?.resume()
        writingSource = DispatchSource.makeWriteSource(fileDescriptor: fd, queue: workQueue)
        writingSource?.setEventHandler() {
            self.writingSource?.suspend()
            self.canWrite = true
            self.checkWriteQueue()
        }
        writingSource?.setCancelHandler() {
            self.writingSource = nil
        }
        writingSource?.resume()
        isOpen = true
	}
    
    deinit {
    }
	
	// MARK: - Listening
	
	func startListening(port: UInt16) throws -> Void {
        socketType = .server
		var address        = sockaddr_in()
		address.sin_family = sa_family_t(UInt16(AF_INET))
		#if os(Linux)
			address.sin_port = htons(port)
		#else
			address.sin_port = CFSwapInt16HostToBig(port)
		#endif
		address.sin_addr.s_addr = UInt32(0)
		
		// Allow quick reusage of the local address if applicable
		var option: Int32 = 1
		setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &option, UInt32(MemoryLayout<Int32>.size))
		
		let result = withUnsafePointer(to: &address) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockAddress in
				bind(fd, sockAddress, UInt32(MemoryLayout<sockaddr_in>.size))
			}
		}
		guard result == 0 else {
			switch(errno) {
			case EBADF:
				print("[\(type(of: self))] Error: Listen socket is a bad file descriptor!")
				throw SocketError.invalidFileDescriptor
			case EADDRINUSE:
				print("[\(type(of: self))] Error: address in use, cannot bind")
				throw SocketError.portInUse
			case EINVAL:
				print("[\(type(of: self))] Error: socket is already bound!")
				throw SocketError.alreadyBound
			default:
				print("[\(type(of: self))] Error: socket is already bound!")
				throw SocketError.unknownError
			}
		}
		guard listen(fd, 0) == 0 else {
			print("[\(type(of: self))] Error: Cannot listen on port: \(port)")
			throw SocketError.portInUse
		}
		print("[\(type(of: self))] Bound on port \(port)")
		
		makeNonBlocking(fd: fd)
        
        readingSource = DispatchSource.makeReadSource(fileDescriptor: fd, queue: workQueue)
        readingSource?.setEventHandler(handler: DispatchWorkItem(block: {
            self.acceptNewClient()
        }))
        readingSource?.resume()
        isOpen = true
	}
    
    // MARK: - Connecting
	
	func connect(host: String, port: UInt16) throws {
        socketType = .client
        var address = sockaddr_in()
        var info: UnsafeMutablePointer<addrinfo>?
        var status: Int32 = getaddrinfo(host, String(port), nil, &info)
        guard status == 0 else {
            throw SocketError.unableToResolveHost
        }
        defer {
            if info != nil {
                freeaddrinfo(info)
            }
        }
        memcpy(&address, info!.pointee.ai_addr, Int(MemoryLayout<sockaddr_in>.size))
        
        var casted = address.asAddr()
        if Darwin.connect(fd, &casted, socklen_t(MemoryLayout<sockaddr_in>.size)) < 0 {
            print("[\(type(of: self))] Error: unable to connect to \(host) \(errno)")
            throw SocketError.unableToConnect
        }
        
        makeNonBlocking(fd: fd)
        
        readingSource = DispatchSource.makeReadSource(fileDescriptor: fd, queue: workQueue)
        readingSource?.setEventHandler(handler: DispatchWorkItem(block: {
            self.readAvailableData()
        }))
        readingSource?.resume()
        writingSource = DispatchSource.makeWriteSource(fileDescriptor: fd, queue: workQueue)
        writingSource?.setEventHandler(handler: DispatchWorkItem(block: {
            self.writingSource?.suspend()
            self.canWrite = true
            self.checkWriteQueue()
        }))
        writingSource?.resume()
        isOpen = true
	}
    
    func disconnect() {
        guard isWriting == false, isReading == false else {
            shouldClose = true
            return
        }
        finalizeClose()
    }
    
    private func finalizeClose() {
        isOpen = false
        delegate?.socketWillDisconnect(self)
        readingSource?.cancel()
        
        shutdown(fd, SHUT_RDWR)
        close(fd)
        delegate?.socketDidDisconnect(self)
    }
}

// MARK: - Reading and accepting

extension Socket {
    func readAvailableData() {
        guard isOpen == true else {
            return
        }
        isReading = true
        let buffSize = 1024
        
        // Using UnsafeMutablePointer here crashes for some reason.
        var buffer: [UInt8] = [UInt8](repeating: 0, count: 0)
        var len = 0
        repeat {
            let part = UnsafeMutablePointer<UInt8>.allocate(capacity: buffSize)
            len = read(fd, part, buffSize)
            if len > 0 {
                buffer += Array(UnsafeMutableBufferPointer(start: part, count: len))
            }
            part.deallocate(capacity: buffSize)
        } while( len == 512 );
        if len <= 0 {
            disconnect()
            return
        }
        
        delegate?.socketDidReadBytes(self, bytes: buffer)
        isReading = false
        if shouldClose == true {
            finalizeClose()
        }
    }
    
    func acceptNewClient() {
        guard isOpen == true else {
            return
        }
        let client = accept(fd, nil, nil)
        guard client != -1 else {
            print("[\(type(of: self))] Unable to accept new client \(errno)")
            return
        }
        if( errno == EMFILE || errno == ENFILE ) {
            let message = errno == EMFILE ? "Maximum of process connections has been reached" : "Maxmimum of system connections has been reached"
            print("[\(type(of: self))] WARNING: \(message)")
            return
        }
        if( errno == EBADF ) {
            print("[\(type(of: self))] Unable to accept new connection: bad file descriptor")
            close(client)
            return
        }
        // TODO: Set up TLS support as well
        delegate?.socketDidAcceptNewClient(self, client: Socket(fd: client))
    }
}

// MARK: - Writing data

extension Socket {
    
    public func send(bytes: [UInt8]) {
        sendBuffer += bytes
        checkWriteQueue()
    }
    
    private func checkWriteQueue() {
        guard isOpen == true else {
            return
        }
        guard canWrite == true else {
            return
        }
        guard sendBuffer.count > 0 else { return }
        isWriting = true
        canWrite = false
        
        let maxBufferSize = 20240
        let maxChunkSize = (maxBufferSize > sendBuffer.count) ? sendBuffer.count : maxBufferSize
        
        var chunk = Array(sendBuffer[0..<maxChunkSize])
        let bytesWritten = write(fd, &chunk, chunk.count)
        if bytesWritten > 0 {
            sendBuffer.removeFirst(bytesWritten)
        }
        writingSource?.resume()
        isWriting = false
        if shouldClose == true {
            finalizeClose()
        }
    }
}
