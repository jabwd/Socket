//
//  SocketDelegate.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//

public protocol SocketDelegate: class {
    func socketDidAcceptNewClient(_ socket: Socket, client: Socket) -> Void
    
    func socketDidReadBytes(_ socket: Socket, bytes: [UInt8]) -> Void
    
    func socketWillDisconnect(_ socket: Socket) -> Void
    func socketDidDisconnect(_ socket: Socket) -> Void
}

// Make the entire protocol optional!
extension SocketDelegate {
    public func socketDidAcceptNewClient(_ socket: Socket, client: Socket) {}
    public func socketDidReadBytes(_ socket: Socket, bytes: [UInt8]) {}
    public func socketWillDisconnect(_ socket: Socket) {}
    public func socketDidDisconnect(_ socket: Socket) {}
}
