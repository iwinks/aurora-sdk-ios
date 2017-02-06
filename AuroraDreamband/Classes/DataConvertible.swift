//
//  DataConvertible.swift
//  Pods
//
//  Created by Rafael Nobre on 03/02/17.
//
//

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

extension DataConvertible {
    
    init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    var data: Data {
        var value = self
        let result = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return result
    }
}

extension Int : DataConvertible { }
extension Int32 : DataConvertible { }
extension Int16 : DataConvertible { }
extension Int8 : DataConvertible { }
extension UInt8 : DataConvertible { }
extension Float : DataConvertible { }
extension Double : DataConvertible { }

extension String: DataConvertible {
    init?(data: Data) {
        self.init(data: data, encoding: .utf8)
    }
    var data: Data {
        // Note: a conversion to UTF-8 cannot fail.
        let result = self.data(using: .utf8)!
        return result
    }
}
