//
//  Connection.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//

public class Connection {

    public enum Status {
        case disconnected
        case disconnecting
        case connecting
        case connected
    }

    public let index: Int
    private(set) var status: Connection.Status {
        didSet {
            delegate?.connectionStatusChanged(self, status: status)
        }
    }

    private let socket: Socket
    private weak var server: Server?

    public weak var delegate: ConnectionDelegate?

    public init(server: Server, index: Int, socket: Socket) {
        self.index  = index
        self.socket = socket
        self.server = server
        status = .connected

        socket.delegate = self
    }

    public func startReading() {
        socket.startReading()
    }

    public func close() {
        guard status != .disconnected else {
            server?.removeConnection(self)
            return
        }
        socket.disconnect()
    }

    public func send(bytes: [UInt8]) {
        socket.send(bytes: bytes)
    }
}

extension Connection: SocketDelegate {
    public func socketDidReadBytes(_ socket: Socket, bytes: [UInt8]) {
        delegate?.connectionDidReceiveBytes(self, bytes: bytes)
    }

    public func socketDidDisconnect(_ socket: Socket) {
        print("[\(type(of: self))] Socket disconnected")
        status = .disconnected
        close()
    }

    public func socketWillDisconnect(_ socket: Socket) {
        status = .disconnecting
    }
}
