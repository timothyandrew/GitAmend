//
//  MarkdownUtil.swift
//  GitAmend
//
//  Created by Timothy Andrew on 20/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

public class MarkdownUtil: NSObject {
    public static func parse(mdUrl: String) -> (String, String)? {
        let regex = try! NSRegularExpression(pattern: #"\[([^]]*)\]\(([^)]*)\)"#, options: [])
        let range = NSRange(location: 0, length: mdUrl.utf16.count)
        let matches = regex.matches(in: mdUrl, options: [], range: range)
        
        guard matches.count > 0 else {
            return nil
        }
        
        let title = Range(matches[0].range(at: 1), in: mdUrl)!
        let url = Range(matches[0].range(at: 2), in: mdUrl)!
        
        return (String(mdUrl[title]), String(mdUrl[url]))
    }
}
