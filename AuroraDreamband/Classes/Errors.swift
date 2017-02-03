//
//  Errors.swift
//  Pods
//
//  Created by Rafael Nobre on 02/02/17.
//
//

public enum AuroraErrors: LocalizedError {
    case maxPayloadExceeded(size: Int)
    case readNothingAttempt
    case unknownReadError
    case notConnected

    public var errorDescription: String? {
        switch self {
        case .maxPayloadExceeded(let size):
            return "Unable to read or write buffer of size \(size). Max payload of \(TRANSFER_MAX_PAYLOAD) bytes exceeded."
            
        case .readNothingAttempt:
            return "Cannot read less than 1 byte."
            
        case .unknownReadError:
            return "Nothing to read and no explicit error thrown."
            
        case .notConnected:
            return "Unable to execute command. You are not connected to Aurora."
        }
    }
}
