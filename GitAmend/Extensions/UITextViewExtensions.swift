//
//  UITextViewExtensions.swift
//  GitAmend
//
//  Created by Timothy Andrew on 20/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

extension UITextView {
    // This is a mess! Does it have to be this difficult/awkward to perform basic string manipulation? :|
    func togglePrefix(_ prefix: String) {
        let range = self.selectedRange
        var text = self.text!
        
        var lowerBound = text[text.startIndex...text.index(text.startIndex, offsetBy: range.location)].lastIndex(of: "\n")!
        var upperBound = text.index(text.startIndex, offsetBy: range.location + range.length)
        
        while true {
            guard lowerBound < upperBound,
                  let currentIndex = text[lowerBound..<upperBound].firstIndex(of: "\n") else {
                break
            }
             
            lowerBound = text.index(after: currentIndex)
            
            let replaceAtLowerBound = self.position(from: self.beginningOfDocument, offset: lowerBound.utf16Offset(in: text))!
            let replaceAtUpperBound = self.position(from: self.beginningOfDocument, offset: text.index(lowerBound, offsetBy: prefix.count).utf16Offset(in: text))!
            
            let replaceAtRangeExcl = self.textRange(from: replaceAtLowerBound, to: replaceAtLowerBound)!
            let replaceAtRangeIncl = self.textRange(from: replaceAtLowerBound, to: replaceAtUpperBound)!
            
            if (self.text(in: replaceAtRangeIncl) == prefix) {
                self.replace(replaceAtRangeIncl, withText: "")
                upperBound = text.index(upperBound, offsetBy: (-1 * prefix.count))
            } else {
                self.replace(replaceAtRangeExcl, withText: prefix)
                upperBound = text.index(upperBound, offsetBy: (prefix.count))
            }
            
            text = self.text!
        }
    }
}
