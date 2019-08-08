//
//  SKScene+Localization.swift
//  Game1010
//
//  Created by Erland Isaksson on 2019-08-08.
//  Copyright © 2019 Erland Isaksson. All rights reserved.
//

import SpriteKit

extension SKScene {
    func localize() {
        enumerateChildNodes(withName: "*") {
            (node, stop) in
            
            let regex = try! NSRegularExpression(pattern: "@\"(.*?)\"")
            if let node = node as? SKLabelNode {
                if let text = node.text {
                    regex.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
                        (result, flags, stop) in
                        
                        
                        if result!.numberOfRanges>0 {
                            for i in 1..<result!.numberOfRanges {
                                let key = text.substring(with: Range(result!.range(at: i), in: text)!)
                                let replaceString = "@\"\(key)\""
                                let replacementString = NSLocalizedString(key, comment: key)
                                print("Replacing: \(replaceString) With: \(replacementString)")
                                node.text = text.replacingOccurrences(of: replaceString, with: replacementString)
                            }
                        }
                    }
                }
            }
        }
        
    }
}
