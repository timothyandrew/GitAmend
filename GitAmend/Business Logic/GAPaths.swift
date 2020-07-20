//
//  GAPaths.swift
//  GitAmend
//
//  Created by Timothy Andrew on 20/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

struct GAPaths {
    static func learningNote(name: String) -> String {
        "content/learning/notes/\(DateUtil.year())/\(DateUtil.monthName())/\(name).md"
    }
}
