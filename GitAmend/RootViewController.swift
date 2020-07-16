//
//  RootViewController.swift
//  GitAmend
//
//  Created by Timothy Andrew on 15/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit
import AuthenticationServices
import Alamofire
import KeychainAccess

extension RootViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

class RootViewController: UISplitViewController {
    private var authSession: ASWebAuthenticationSession? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.authSession = GithubAPIAuth.authSession()
        authSession?.presentationContextProvider = self
        
        // TODO: More sophisticated auth; use UI to prompt the user to kickoff authentication
        // TODO: Don't allow UI interaction until auth is done
        if GithubAPIAuth.accessToken() != nil {
            print("Already authenticated!")
        } else {
            print("Need to authenticate…")
            authSession?.start()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
