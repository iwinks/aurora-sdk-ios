//
//  String+Slicing.swift
//  SGI
//
//  Created by Rafael Nobre on 01/04/17.
//  Copyright © 2017 Rafael Nobre. All rights reserved.
//

extension String {
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
    
}
