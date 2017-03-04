//
//  Command.swift
//  Pods
//
//  Created by Rafael Nobre on 28/02/17.
//
//

import UIKit

class Command: NSObject {
    
    private var data: Data?
    var currentChunk = -1
    var chunkCount = 0
    private(set) var command: String
    
    var error: Error?
    
    private var pendingOperations = 0 {
        didSet {
            if pendingOperations == 0 && finished {
                log("finished command after last response came in")
                handleFinish()
            }
        }
    }
    private var status: UInt8 = 0
    private var finished = false
    
    init(_ command: String, data: Data? = nil) {
        self.command = command
        self.data = data
    }
    
    override var description: String {
        get {
            return "Command: \(command), completed: \(finished && pendingOperations == 0), response: \(try? responseString())"
        }
    }
    
    var successHandler: ((Command) -> Void)?
    var errorHandler: ((Error) -> Void)?
    var response = [String]()
    var output = Data()
    
    func responseString() -> String {
        return response.joined(separator: "\n")
    }
    
    func append(response handler: () throws -> Data) throws {
        pendingOperations += 1
        
        let data = try handler()
        if let line = String(data: data, encoding: .utf8) {
            response.append(line)
        }
        else {
            throw AuroraErrors.unparseableCommandResult
        }
        log("Appended response line with \(data.count) bytes. Total lines \(response.count)")
        
        pendingOperations -= 1
    }
    
    func append(output handler: () throws -> Data) throws {
        pendingOperations += 1
        
        let data = try handler()
        output.append(data)
        log("Appended output chunk with \(data.count) bytes. Total bytes \(output.count)")
        
        pendingOperations -= 1
    }
    
    func finish(status: UInt8) {
        finished = true
        self.status = status
        
        if pendingOperations == 0 {
            log("finished command")
            handleFinish()
            
        }
        else {
            log("finished command while busy, waiting for last response to come in...")
        }
    }
    
    func nextChunk() -> Data {
        currentChunk += 1
        
        let trailingData = "\r\r\r\r".data
        guard let data = data else {
            return trailingData
        }
        chunkCount = data.count / TRANSFER_MAX_PAYLOAD
        
        if currentChunk > chunkCount {
            return trailingData
        }
        
        let chunkStart = currentChunk * TRANSFER_MAX_PAYLOAD
        var chunkEnd = chunkStart + TRANSFER_MAX_PAYLOAD
        
        if chunkEnd > data.count {
            chunkEnd = data.count
        }
        
        var chunk = data.subdata(in: chunkStart..<chunkEnd)
        
        if currentChunk == chunkCount && chunk.count + trailingData.count <= TRANSFER_MAX_PAYLOAD {
            chunk.append(trailingData)
        }
        
        return chunk
    }
    
    private func handleFinish() {
        if status != 0 {
            errorHandler?(AuroraErrors.commandError(code: status, message: try? responseString()))
        }
        else if let error = error {
            errorHandler?(error)
        }
        else {
            successHandler?(self)
        }
    }
}
