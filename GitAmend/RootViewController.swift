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
        
        let clientId = Bundle.main.object(forInfoDictionaryKey: "GIT_AMEND_CLIENT_ID") as! String
        let clientSecret = Bundle.main.object(forInfoDictionaryKey: "GIT_AMEND_CLIENT_SECRET") as! String
               
        guard let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=gitamend://callback") else {
            // TODO: UI alert
            print("Invalid URL")
            return
        }
        let scheme = "gitamend"
        self.authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { url, error in
            guard error == nil, let url = url else {
                // TODO: UI alert
                print("Failed 1")
                return
            }
            
            guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                let index = items.firstIndex(where: { $0.name == "code" }),
                let code = items[index].value
                else { return }
                        
            AF.request("https://github.com/login/oauth/access_token", method: .post, parameters: [
                "client_id": clientId,
                "client_secret": clientSecret,
                "code": code,
            ], encoder: URLEncodedFormParameterEncoder.default).responseString { response in
                guard response.response?.statusCode == 200,
                    let response = response.value,
                    let url = URL(string: response) else {
                    // TODO: UI alert
                    print("Failed 2")
                    return
                }
                                
                let segments = url.absoluteString.split(separator: "&")
                let split = segments.compactMap { pair -> (Substring, Substring)? in
                    let kv = pair.split(separator: "=")
                    if (kv.count == 2) {
                        return (kv[0], kv[1])
                    } else {
                        return nil
                    }
                }

                let dict: Dictionary = Dictionary(uniqueKeysWithValues: split)
                let keychain = Keychain(service: "net.timothyandrew.GitAmend")
                keychain["access_token"] =  String(dict["access_token"]!)
                keychain["refresh_token"] = String(dict["refresh_token"]!)
                
                print("Auth done!")
            }
            
        }

        authSession?.presentationContextProvider = self
        authSession?.start()
//        let keychain = Keychain(service: "net.timothyandrew.GitAmend")
//        print(keychain["refresh_token"])
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
