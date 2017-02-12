//
//  Array+Remove.swift
//  Pods
//
//  Created by Rafael Nobre on 12/02/17.
//
//

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ element: Element) {
        if let index = index(of: element) {
            remove(at: index)
        }
    }
}
