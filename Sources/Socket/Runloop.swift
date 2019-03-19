//
//  Runloop.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//
import Dispatch

public class Runloop {

    public static let shared = Runloop()
    private let group: DispatchGroup

    init() {
        group = DispatchGroup()
        group.enter()
    }

    public func run() {
        group.wait()
    }

    public func stop() {
        group.leave()
    }
}
