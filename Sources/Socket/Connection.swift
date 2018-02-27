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
    private(set) var status: Connection.Status
    
    private let socket: Socket
    private weak var server: Server?
    
    init(server: Server, index: Int, socket: Socket) {
        self.index  = index
        self.socket = socket
        self.server = server
        status = .connected
        
        socket.delegate = self
    }
    
    deinit {
    }
    
    func close() {
        guard status != .disconnected else {
            server?.connectionWillClose(self)
            return
        }
        socket.disconnect()
    }
}

extension Connection: SocketDelegate {
    public func socketDidReadBytes(_ socket: Socket, bytes: [UInt8]) {
        print("Read some bytes: \(bytes)")
        
        let response = "HTTP/1.1 200 OK\r\nServer: Exurion (unix)\r\nConnection: closed"
        socket.send(bytes: Array(response.utf8))
        socket.disconnect()
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
