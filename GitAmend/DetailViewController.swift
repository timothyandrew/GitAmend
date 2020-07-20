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

class DetailViewController: UIViewController, WKNavigationDelegate {
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
        let insets = self.detailView.safeAreaInsets
        let frame = self.detailView.frame.inset(by: insets)

        switch state {
        case .Viewing:
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.startEditing))]
            self.webView = WKWebView(frame: frame)
            self.webView!.navigationDelegate = self
            self.textView?.removeFromSuperview()
            self.detailView.addSubview(self.webView!)

        case .Editing:
            let detailFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 44)
            let toolbarFrame = CGRect(x: 0, y: frame.maxY - 44, width: frame.width, height: 44)
            
            let toolbar = UIToolbar(frame: toolbarFrame)
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .camera, target: nil, action: nil)
            ]
            self.detailView.addSubview(toolbar)
            
            self.navigationItem.rightBarButtonItems = [
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.stopEditing)),
                UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.commitChanges))
            ]
            self.textView = UITextView(frame: detailFrame)
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
            present(alert, animated: true) {
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
        self.present(fullscreenAlert, animated: true) {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var maybeRepo: GithubAPIRepository?
    var maybeFile: GithubAPIFile?
    
    // MARK: - Delegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           url.host != "timothyandrew.net" {
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
}
