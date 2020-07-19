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
        if let file = maybeFile {
            self.textContent.delegate = self
            self.textContent.text = "Loading…"

            // TODO: Configurable repo
            file.fetchContents("timothyandrew/kb") { contents, error in
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
        guard let repo = self.maybeRepo,
              let file = self.maybeFile else {
            print("No `detail` found; shouldn't ever get here!")
            return
        }
        
        print("Attempting to commit file changes")
        let fullscreenAlert = AlertUtil.blockScreen()
        self.present(fullscreenAlert, animated: true)

        repo.persistFile(path: file.path, contents: self.textContent.text) { shas in
            fullscreenAlert.dismiss(animated: true)

            guard let (blobSha, _, commitSha) = shas else {
                let alert = AlertUtil.dismiss(title: "Failed!", message: "Couldn't create a commit; changes were _not_ saved.")
                self.present(alert, animated: true)
                print("Failed to commit file")
                return
            }
            
            file.sha = blobSha
            let alert = AlertUtil.dismiss(title: "Success!", message: "Created commit \(commitSha)")
            self.present(alert, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var maybeRepo: GithubAPIRepository?
    var maybeFile: GithubAPIFile?
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.commitChanges))
    }
}
