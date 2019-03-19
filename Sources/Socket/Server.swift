//
//  Server.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//
import Dispatch

public typealias ServerConnectionCallback = (Socket) -> SocketDelegate

public class Server: SocketDelegate {

    private let listeningSocket: Socket
    private var connections: [Int: SocketDelegate]

    private var currentIndex: Int
    private let syncQueue: DispatchQueue
	private let syncGroup: DispatchGroup

    public var newConnectionHandler: ServerConnectionCallback?

    public init(port: UInt16) throws {
		syncGroup = DispatchGroup()
        connections = [:]
        currentIndex = 0
        syncQueue = DispatchQueue(label: "exurion.synchronization")
        listeningSocket = Socket()
        listeningSocket.delegate = self
        try listeningSocket.startListening(port: port)
    }

    public func socketDidAcceptNewClient(_ socket: Socket, client: Socket) {
		syncGroup.enter()
		syncQueue.sync {
            guard let conn = self.newConnectionHandler?(client) else {
                return
            }
			connections[currentIndex] = conn
			currentIndex += 1
			print("[\(type(of: self))] Connection opened: \(connections.count) (Since start: \(currentIndex))")
			syncGroup.leave()
		}
		syncGroup.wait()
    }

    // MARK: -

    func connectionWillClose(_ connection: Connection) {
		syncGroup.enter()
        syncQueue.sync {
            connections.removeValue(forKey: connection.index)
            print("[\(type(of: self))] Connection closed: \(connections.count)")
            syncGroup.leave()
        }
		syncGroup.wait()
    }
}
