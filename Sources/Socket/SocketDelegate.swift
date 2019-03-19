//
//  SocketDelegate.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//

public protocol SocketDelegate: AnyObject {
    var index: Int { get }
    func socketDidAcceptNewClient(_ socket: Socket, client: Socket)
    func socketDidReadBytes(_ socket: Socket, bytes: [UInt8])
    func socketWillDisconnect(_ socket: Socket)
    func socketDidDisconnect(_ socket: Socket)
}

extension SocketDelegate {
    public func socketDidAcceptNewClient(_ socket: Socket, client: Socket) {}
    public func socketDidReadBytes(_ socket: Socket, bytes: [UInt8]) {}
    public func socketWillDisconnect(_ socket: Socket) {}
    public func socketDidDisconnect(_ socket: Socket) {}
}
