//
//  SocketError.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//

public enum SocketError: Error {
    case portInUse
    case invalidFileDescriptor
    case alreadyBound
    case unknownError

    case unableToResolveHost
    case unableToConnect

    case unableToDetermineCoreCount
}
