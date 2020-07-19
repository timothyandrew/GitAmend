//
//  AlertUtil.swift
//  GitAmend
//
//  Created by Timothy Andrew on 19/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class AlertUtil: NSObject {
    static func dismiss(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        return alert
    }
}
