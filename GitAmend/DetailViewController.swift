//
//  DetailViewController.swift
//  GitAmend
//
//  Created by Timothy Andrew on 15/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit
import Ink
import WebKit

class DetailViewController: UIViewController, UITextViewDelegate {
    enum State {
        case Viewing
        case Editing
    }
    
    @IBOutlet var detailView: UIView!
    var textView: UITextView?
    var webView: WKWebView?
    var state = State.Viewing
    var text: String?
    
    func configureView() {
        switch state {
        case .Viewing:
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.startEditing))]
            self.webView = WKWebView(frame: self.detailView.frame)
            self.textView?.removeFromSuperview()
            self.detailView.addSubview(self.webView!)

        case .Editing:
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.stopEditing)),
                UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.commitChanges))
            ]
            self.textView = UITextView(frame: self.detailView.frame)
            self.textView!.delegate = self
            self.textView!.isEditable = true
            self.textView!.isSelectable = true
            
            self.webView?.removeFromSuperview()
            self.detailView.addSubview(self.textView!)
        }
        
        guard text == nil else {
            configureText()
            return
        }
        
        if let file = maybeFile {
            self.title = file.prettyFilename(trimPath: false)
            
            let alert = AlertUtil.blockScreen()
            present(alert, animated: true)

            // TODO: Configurable repo
            file.fetchContents("timothyandrew/kb") { contents, error in
                guard let text = contents else {
                    // use error
                    return
                }
            
                self.text = text
                self.configureText()
                alert.dismiss(animated: true)
            }
        }
    }
    
    func configureText() {
        switch state {
        case .Viewing:
            let html = MarkdownParser().html(from: self.text!)
            self.webView!.loadHTMLString(HTMLUtil.defaultTemplate(content: html), baseURL: URL(string: "https://timothyandrew.net"))
        case .Editing:
            self.textView!.text = self.text!
        }
    }
    
    @objc func startEditing() {
        self.state = .Editing
        configureView()
    }
    
    @objc func stopEditing() {
        self.state = .Viewing
        self.configureView()
    }
    
    @objc func commitChanges() {
        guard let repo = self.maybeRepo,
              let file = self.maybeFile else {
            print("No `detail` found; shouldn't ever get here!")
            return
        }
        
        self.text = self.textView!.text
        
        print("Attempting to commit file changes")
        let fullscreenAlert = AlertUtil.blockScreen()
        self.present(fullscreenAlert, animated: true)

        repo.persistFile(path: file.path, contents: self.text!) { shas in
            fullscreenAlert.dismiss(animated: true)

            guard let (blobSha, _, commitSha) = shas else {
                let alert = AlertUtil.dismiss(title: "Failed!", message: "Couldn't create a commit; changes were _not_ saved.")
                self.present(alert, animated: true)
                print("Failed to commit file")
                return
            }
            
            file.sha = blobSha

            self.stopEditing()
            
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
    
    // MARK: - Text View Delegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        true
    }
}
