//
//  DateUtil.swift
//  GitAmend
//
//  Created by Timothy Andrew on 20/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class DateUtil: NSObject {
    static func monthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter.string(from: Date()).lowercased()
    }
    
    static func year() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
}
