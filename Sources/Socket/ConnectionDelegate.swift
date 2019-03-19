//
//  ConnectionDelegate.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 01/03/2018.
//

public protocol ConnectionDelegate: class {
    func connectionStatusChanged(_ connection: Connection, status: Connection.Status)
    func connectionDidReceiveBytes(_ connection: Connection, bytes: [UInt8])
}
