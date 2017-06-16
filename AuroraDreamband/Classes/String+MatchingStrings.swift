//
//  String+MatchingStrings.swift
//  Pods
//
//  Created by Rafael Nobre on 15/06/17.
//
//

import UIKit

extension String {
    func matchingStrings(regex: String) throws -> [[String]] {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
                ? nsString.substring(with: result.rangeAt($0))
                : ""
            }
        }
    }
}
