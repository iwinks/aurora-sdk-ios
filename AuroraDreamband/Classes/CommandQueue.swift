//
//  CommandQueue.swift
//  Pods
//
//  Created by Rafael Nobre on 28/02/17.
//
//

import UIKit

class CommandQueue {
    
    var current: Command? {
        get {
            return commands.first
        }
    }
    private var commands = [Command]()
    private var handlers = [() -> Void]()
    
    func enqueue(command: Command, readyHandler: @escaping () -> Void) {
        commands.append(command)
        handlers.append(readyHandler)
        if commands.count == 1 {
            readyHandler()
        }
    }
    
    func dequeue(command: Command) {
        if let index = commands.index(of: command) {
            commands.remove(at: index)
            let _ = handlers.remove(at: index)
        }
        handlers.first?()
    }
}

