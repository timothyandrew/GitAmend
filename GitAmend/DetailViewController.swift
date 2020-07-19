//
//  DetailViewController.swift
//  GitAmend
//
//  Created by Timothy Andrew on 15/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textContent: UITextView!
    
    func configureView() {
        if let detail = detailItem {
            self.textContent.delegate = self
            self.textContent.text = "Loading…"

            // TODO: Configurable repo
            detail.fetchContents("timothyandrew/kb") { contents, error in
                guard let text = contents else {
                    // use error
                    return
                }
                
                self.textContent.text = text
            }
        }
    }
    
    @objc
    func commitChanges() {
        guard let detail = self.detailItem else {
            print("No `detail` found; shouldn't ever get here!")
            return
        }
        
//        detail.save(overridingContentsWith: self.textContent.text, "timothyandrew/kb") { result in
//            // TODO: Don't allow UI action until action completes
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var detailItem: GithubAPIFile?
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.commitChanges))
    }
}
