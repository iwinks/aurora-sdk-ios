//
//  Command.swift
//  Pods
//
//  Created by Rafael Nobre on 28/02/17.
//
//

class Command: NSObject {
    
    var data: Data?
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
    var hasData = false
    lazy var output: Data = {
        return Data()
    }()
    
    func responseString() -> String {
        return response.joined(separator: "\n")
    }
    
    func responseTable() throws -> [[String: String]] {
        guard let header = response.first else {
            throw AuroraErrors.unparseableCommandResult
        }
        
        let headerRow = header.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let rows = response.flatMap { row -> [String : String]? in
            guard row != header else {
                return nil
            }
            
            let cols = row.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            var tableRow = [String: String]()
            for (index, element) in cols.enumerated() {
                tableRow[headerRow[index]] = cols[index]
            }
            
            return tableRow
        }
        
        return rows
    }
    
    func responseObject() throws -> [String: String] {
        var object = [String: String]()
        
        for line in response {
            let pair = line.components(separatedBy: " : ")
            guard pair.count >= 2 else {
                throw AuroraErrors.responseTypeIncorrect
            }
            object[pair[0]] = pair[1]
        }
        
        return object
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
        
        pendingOperations -= 1
    }
    
    func append(output handler: () throws -> Data) throws {
        pendingOperations += 1
        
        let data = try handler()
        hasData = true
        output.append(data)
        log("Appended output chunk with \(data.count) bytes and \((data as NSData).description) content. Total bytes \(output.count)")
        
        pendingOperations -= 1
    }
    
    func finish(status: UInt8) {
        finished = true
        self.status = status
        
        if pendingOperations == 0 {
            handleFinish()
        }
    }
    
    func checksum() -> UInt32? {
        let crc = try? responseObject()["CRC"]
        if let crc = crc ?? nil {
            return UInt32(crc.replacingOccurrences(of: "0x", with: ""), radix: 16)
        }
        return nil
    }
    
    private func handleFinish() {
        log("|====================================\nCommand: \(command)\nStatus: \(status) Error: \(error)\nResponse: \(responseString())\n====================================|")
        if status != 0 {
            errorHandler?(AuroraErrors.commandError(code: status, message: (try? responseObject())?["Message"]))
        }
        else if let error = error {
            errorHandler?(error)
        }
        else {
            successHandler?(self)
        }
    }
}
