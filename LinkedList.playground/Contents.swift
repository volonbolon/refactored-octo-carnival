//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

// https://en.wikipedia.org/wiki/Linked_list#Doubly_linked_vs._singly_linked
public class Node<T:Equatable> {
    typealias NodeType = Node<T>
    
    public let value:T
    var next:NodeType? = nil
    var previous:NodeType? = nil
    
    public init(value:T) {
        self.value = value
    }
}

extension Node:CustomStringConvertible {
    public var description:String {
        get {
            return "Node(\(self.value))"
        }
    }
}

public final class LinkedList<T:Equatable> {
    public typealias NodeType = Node<T>
    
    fileprivate var first:NodeType? {
        didSet {
            if self.last == nil {
                self.last = first
            }
        }
    }
    
    fileprivate var last:NodeType? {
        didSet {
            if self.first == nil {
                self.first = last
            }
        }
    }
    
    public fileprivate(set) var count:Int = 0
    
    public var isEmpty:Bool {
        get {
            return self.count == 0
        }
    }
    
    // Empty List
    public init() {}
    
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == T {
        for e in elements {
            self.append(value:e)
        }
    }
}

extension LinkedList {
    public func append(value: T) {
        let previouslast = last
        last = NodeType(value: value)
        
        last?.previous = previouslast
        previouslast?.next = last
        
        count += 1
    }
}

extension LinkedList {
    private func iterate(block:(_ node:NodeType, _ index:Int) throws -> NodeType?) rethrows -> NodeType? {
        var node = first
        var index = 0
        
        while node != nil {
            let result = try block(node!, index)
            if result != nil {
                return result
            }
            index += 1
            node = node?.next
        }
        
        return nil
    }
    
    // Complexity: O(n)
    public func nodeAt(index:Int) -> NodeType {
        precondition(index >= 0 && index < self.count, "Index \(index) out of bounds")
        let r = self.iterate { (n:NodeType, i:Int) -> NodeType? in
            if i == index {
                return n
            }
            return nil
        }
        return r!
    }
    
    public func valueAt(index:Int) -> T {
        let n = self.nodeAt(index: index)
        return n.value
    }
    
    // Complexity: O(1)
    public func remove(node:NodeType) {
        let nextNode = node.next
        let previousNode = node.previous
        
        // Only one element
        if node === self.first && node === self.last {
            self.first = nil
            self.last = nil
        } else if node === self.first {
            self.first = node.next
        } else if node === self.last {
            self.last = node.previous
        } else {
            previousNode?.next = nextNode
            nextNode?.previous = previousNode
        }
        self.count -= 1
    }
    
    // Complexity: O(n)
    public func removeAt(index:Int) {
        precondition(index >= 0 && index < self.count, "Index \(index) out of bounds")
        
        let r = self.iterate { (n:NodeType, i:Int) -> NodeType? in
            if i == index {
                return n
            }
            return nil
        }
        self.remove(node: r!)
    }
}

public struct LinkedListIterator<T: Equatable>: IteratorProtocol {
    public typealias Element = Node<T>
    
    private var currentNode:Element?
    
    fileprivate init(firstNode:Element?) {
        self.currentNode = firstNode
    }
    
    public mutating func next() -> LinkedListIterator.Element? {
        let n = self.currentNode
        self.currentNode = self.currentNode?.next
        
        return n
    }
}

extension LinkedList:Sequence {
    public typealias Iterator = LinkedListIterator<T>
    
    public func makeIterator() -> LinkedList.Iterator {
        return LinkedListIterator(firstNode:first)
    }
}

// CopyOnWrite
// http://chris.eidhof.nl/post/struct-semantics-in-swift/
extension LinkedList {
    func copy() -> LinkedList<T> {
        let copiedList = LinkedList<T>()
        
        for e in self {
            copiedList.append(value: e.value)
        }
        
        return copiedList
    }
}

public struct LinkedListCOW<T:Equatable> {
    public typealias NodeType = Node<T>
    
    fileprivate var storage:LinkedList<T>
    fileprivate var mutableStorage:LinkedList<T> {
        mutating get {
            // lets copy storage if it is shared.
            if !isKnownUniquelyReferenced(&storage) {
                self.storage = self.storage.copy()
            }
            // Otherwise, it's safe to pass storage
            return self.storage
        }
    }
    
    public init() {
        self.storage = LinkedList()
    }
    
    public init<S: Sequence>(_ elements: S) where S.Iterator.Element == T {
        storage = LinkedList(elements)
    }
    
    public var count:Int {
        get {
            return self.storage.count
        }
    }
    
    public var isEmpty:Bool {
        get {
            return self.storage.isEmpty
        }
    }
    
    public mutating func append(value:T) {
        self.mutableStorage.append(value: value)
    }
    
    public func nodeAt(index:Int) -> NodeType {
        return self.storage.nodeAt(index: index)
    }
    
    public func valueAt(index:Int) -> T {
        let n = self.nodeAt(index: index)
        return n.value
    }
    
    public mutating func remove(node:NodeType) {
        self.mutableStorage.remove(node: node)
    }
    
    public mutating func removeAt(index:Int) {
        self.mutableStorage.removeAt(index: index)
    }
}

extension LinkedListCOW:CustomStringConvertible {
    public var description:String {
        get {
            let a = UnsafeMutableRawPointer(Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque())
            return "LinkedListCOW(storage: \(a))"
        }
    }
}

extension LinkedList {
    func lastTwo() -> (NodeType, NodeType)? {
        guard self.count >= 2 else {
            return nil
        }
        let t = (self.nodeAt(index: self.count-1), self.nodeAt(index: self.count-2))
        return t
    }
}

let list1 = LinkedListCOW([1, 2, 3])
var list2 = list1

print("List 1: \(list1), count: \(list1.count)")
print("List 2: \(list2), count: \(list2.count)")

let first1 = list1.nodeAt(index: 0)
let first2 = list2.nodeAt(index: 0)

print("List 1 first node: \(list1)")
print("List 2 first node: \(list2)")

print("Modify list 2")
list2.append(value: 4) // Modify list2 causes copy

print("List 1: \(list1), count: \(list1.count)")
print("List 2: \(list2), count: \(list2.count)")

let ll = LinkedList<Int>()
print(ll)

for i in 1...10 {
    let p = pow(2, i)
    let r = NSDecimalNumber(decimal: p)
    ll.append(value: Int(r))
}

for n in ll {
    print("\(n)")
}

print("first \(ll.first!.value)")

let values:[Int] = ll.map { (n:Node<Int>) -> Int in
    return n.value
}
print(values)

print(ll.lastTwo()!.0.value)

var a:[Int] = []
for i in 1...10 {
    let p = pow(2, i)
    let r = NSDecimalNumber(decimal: p)
    a.append(Int(r))
}
for i in 0..<(a.count-1) {
    print(a[i])
}
