//
//  WorkQueuePool.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//
import Dispatch

final class WorkQueuePool {
    public static let shared = WorkQueuePool()
	private let pool: [DispatchQueue]
	private var currentIndex: Int = 0

	var nextQueue: DispatchQueue {
        if currentIndex > pool.count {
            currentIndex = 0
        }
		defer {
			currentIndex += 1
		}
		return pool[currentIndex % pool.count]
	}

	init() {
        let num = sysconf(_SC_NPROCESSORS_ONLN)
        guard num > 0 else {
            print("[Socket] Error: Unable to determine core count, falling back to 1 work queue.")
            pool = [
                DispatchQueue(label: "exurion.work.0")
            ]
            return
        }
        var dynamicPool: [DispatchQueue] = []
        for i in 0..<num {
            let queue = DispatchQueue(label: "exurion.work.\(i)")
            dynamicPool.append(queue)
        }
		pool = dynamicPool
	}
}
