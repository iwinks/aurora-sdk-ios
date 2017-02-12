//
//  Log.swift
//  Pods
//
//  Created by Rafael Nobre on 12/02/17.
//
//

internal var _loggingEnabled = false
func log(_ message: String) {
    if _loggingEnabled {
        print(message)
    }
}
