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
    
    static func blockScreen() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)

        return alert
    }
    
    static func sheet(title: String, actions: [(String, (UIAlertAction) -> Void)]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for (title, completion) in actions {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: completion))
        }
        
        
        return alert
    }
}
