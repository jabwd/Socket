 //
//  ByteBuffer.swift
//  Socket
//
//  Created by Antwan van Houdt on 03/04/2019.
//

import Foundation

 public struct ByteBuffer {
    private var backingStore: UnsafeMutableRawPointer
    private var capacity: Int
    private var index: Int = 0

    init(initialSize size: Int) {
        capacity = size
        backingStore = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1)
    }
 }
