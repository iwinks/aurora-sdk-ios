//
//  Constants.swift
//  Pods
//
//  Created by Rafael Nobre on 28/01/17.
//
//

let TRANSFER_MAX_PACKET_LENGTH = 20
let TRANSFER_MAX_PAYLOAD = 128

public enum SleepStage: Int {
    case unknown = 0
    case awake = 1
    case light = 2
    case deep = 3
    case rem = 4
}
