//
//  CategoryTree.swift
//  QuickTutor
//
//  Created by QuickTutor on 4/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

class Node<T> {
    var value: T
    var children: [Node] = []
    weak var parent: Node?

    init(value: T) {
        self.value = value
    }

    func add(child: Node) {
        children.append(child)
        child.parent = self
    }

    func remove(child: Node) {
        children.remove(at: child.)
        child.parent = nil
    }
}

extension Node where T: Equatable {
    // 2.
    func remove(value: T) {
        if value == self.value {
            remove
        }
        for child in children {
            if let found = child.search(value: value) {
                return found
            }
        }
        return nil
    }
}
