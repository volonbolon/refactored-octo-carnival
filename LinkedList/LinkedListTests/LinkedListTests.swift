//
//  LinkedListTests.swift
//  LinkedListTests
//
//  Created by Ariel Rodriguez on 4/24/17.
//  Copyright © 2017 VolonBolon. All rights reserved.
//

import XCTest
@testable import LinkedList

class LinkedListTests: XCTestCase {
    var linkedList: LinkedList<Int>!

    override func setUp() {
        super.setUp()

        let ll = LinkedList<Int>()
        for i in 1...10 {
            let p = pow(2, i)
            let r = NSDecimalNumber(decimal: p)
            ll.append(value: Int(r))
        }
        self.linkedList = ll
    }

    override func tearDown() {
        self.linkedList = nil
        super.tearDown()
    }

    func testCount() {
        XCTAssert(self.linkedList!.count == 10, "linkedList should contain 10 elements")
    }

    func testIsEmpty() {
        XCTAssertFalse(self.linkedList.isEmpty)
    }

    func testInitWithSequence() {
        // Believe it or not, it has [some](https://en.wikipedia.org/wiki/Look-and-say_sequence) interesting properties
        let s = [1, 11, 21, 1211, 111221]
        let ll = LinkedList(s)
        XCTAssert(ll.count == 5, "ll should contain 5 elements")
    }

    func testAppend() {
        self.linkedList.append(value: 2048)
        XCTAssert(self.linkedList.count == 11, "ll should contains 11 elements now")
        let first = self.linkedList.valueAt(index: 0)
        XCTAssert(first == 2, "first \(first) should be 2")
        let last = self.linkedList.valueAt(index: 10)
        XCTAssert(last == 2048, "last \(last) should be 2048")
    }

    func testRemove() {
        self.linkedList.removeAt(index: 2)
        XCTAssert(self.linkedList.count == 9, "Now we should have 9 elements")
        let element1 = self.linkedList.valueAt(index: 1)
        XCTAssert(element1 == 4, "element1 \(element1) should be 4")
        let element2 = self.linkedList.valueAt(index: 2)
        XCTAssert(element2 == 16, "element1 \(element2) should be 16")
    }

    func testDropLast() {
        self.linkedList.dropLast()
        XCTAssert(self.linkedList.count == 9, "Now we should have 9 elements")
        let l = self.linkedList.nodeAt(index: self.linkedList.count-1)
        XCTAssertTrue(l.value == 512, "l \(l.value) should be 512")
    }
}
