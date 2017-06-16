//
//  FileHelper.swift
//  AuroraDreamband
//
//  Created by Rafael Nobre on 15/06/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class FileHelper {
    
    class func string(with name: String, `extension`: String) -> String {
        let string = String(data: FileHelper.data(with: name, extension: `extension`), encoding: String.Encoding.utf8)
        return string!
    }
    
    class func data(with name: String, `extension`: String) -> Data {
        let path = Bundle(for: self).path(forResource: name, ofType: `extension`)
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
        return data!
    }

}
