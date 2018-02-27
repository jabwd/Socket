//
//  Server.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//
import Dispatch

class Server: SocketDelegate {
    
    private let listeningSocket: Socket
    private var connections: [Int: Connection]

    private var currentIndex: Int
    private let syncQueue: DispatchQueue
	private let syncGroup: DispatchGroup
    
    init(port: UInt16) throws {
		syncGroup = DispatchGroup()
        connections = [:]
        currentIndex = 0
        syncQueue = DispatchQueue(label: "serverSyncQueue")
        listeningSocket = Socket()
        listeningSocket.delegate = self
        try listeningSocket.startListening(port: port)
    }
    
    func socketDidAcceptNewClient(_ socket: Socket, client: Socket) {
        print("[\(type(of: self))] New socket accepted")
		syncGroup.enter()
		let conn = Connection(server: self, index: currentIndex, socket: client)
		syncQueue.sync {
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
