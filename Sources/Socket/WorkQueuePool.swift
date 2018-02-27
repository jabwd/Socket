//
//  WorkQueuePool.swift
//  SocketPackageDescription
//
//  Created by Antwan van Houdt on 27/02/2018.
//
import Dispatch

class WorkQueuePool {
	static let shared = WorkQueuePool()
	
	private let pool: [DispatchQueue]
	private var currentIndex: Int = 0
	
	var nextQueue: DispatchQueue {
		defer {
			currentIndex += 1
		}
		return pool[currentIndex % pool.count]
	}
	
	init() {
		pool = [
			DispatchQueue(label: "workQueue.0"),
			DispatchQueue(label: "workQueue.1"),
			DispatchQueue(label: "workQueue.2"),
			DispatchQueue(label: "workQueue.3"),
			DispatchQueue(label: "workQueue.4"),
			DispatchQueue(label: "workQueue.5"),
		]
	}
}
