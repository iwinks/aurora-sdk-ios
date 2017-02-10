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
    case unknownSubscribeError
    case unknownStateError
    case notConnected
    case commandError(code: UInt8, message: String?)
    case unparseableCommandResult
    case commandNotFinished
    case commandNotFound

    public var errorDescription: String? {
        switch self {
        case .maxPayloadExceeded(let size):
            return "Unable to read or write buffer of size \(size). Max payload of \(TRANSFER_MAX_PAYLOAD) bytes exceeded."
            
        case .readNothingAttempt:
            return "Cannot read less than 1 byte."
            
        case .unknownReadError:
            return "Nothing to read and no explicit error thrown."
            
        case .unknownSubscribeError:
            return "Unable to subscribe to characteristic and no explicit error thrown."
        
        case .unknownStateError:
            return "Unrecognizable state."
            
        case .notConnected:
            return "Unable to execute command. You are not connected to Aurora."
            
        case .commandError(let code, let message):
            return "Command failed with error code: \(code). Message: \(message)"
            
        case .unparseableCommandResult:
            return "Unable to convert command result to lines."
            
        case .commandNotFinished:
            return "The command is not finished yet."
            
        case .commandNotFound:
            return "There is no command in execution."
        }
    }
}
