//
//  Data+Scanning.swift
//  Pods
//
//  Created by Rafael Nobre on 19/12/16.
//
//

import UIKit

public extension Data {
    public func scanValue<T: SignedInteger>(start: Int, length: Int) -> T {
        return self.subdata(in: start..<start+length).withUnsafeBytes {
            (pointer: UnsafePointer<T>) -> T in
            return pointer.pointee
        }
    }
}
