//
//  ProfileSetting+Equatable.swift
//  Pods
//
//  Created by Rafael Nobre on 16/06/17.
//
//

import UIKit

extension ProfileSetting: Equatable {
}

public func ==(lhs: ProfileSetting, rhs: ProfileSetting) -> Bool {
    return lhs.key == rhs.key && lhs.value == rhs.value    
}
