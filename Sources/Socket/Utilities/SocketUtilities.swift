#if os(Linux)
	import Glibc
#else
	import Darwin
	import CoreFoundation
#endif

extension Socket {
    func setNonBlocking() {
        makeNonBlocking(fd: fd)
    }
}

func makeNonBlocking(fd: Int32) {
	let flags = fcntl(fd, F_GETFL, 0)
	_ = fcntl(fd, F_SETFL, flags | O_NONBLOCK)
}

public enum ByteOrder {
	case littleEndian
	case bigEndian

	static var current: ByteOrder {
		let control: UInt32 = 0x12345678
		let endian = control.bigEndian
		return endian == control ? .bigEndian : .littleEndian
	}
}

public extension sockaddr_in {
    ///
    /// Cast to sockaddr
    ///
    /// - Returns: sockaddr
    ///
    public func asAddr() -> sockaddr {
        var temp = self
        let addr = withUnsafePointer(to: &temp) {
            return UnsafeRawPointer($0)
        }
        return addr.assumingMemoryBound(to: sockaddr.self).pointee
    }
}
