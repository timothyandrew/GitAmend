//
//  Auth.swift
//  GitAmend
//
//  Created by Timothy Andrew on 17/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit
import AuthenticationServices
import Alamofire
import KeychainAccess

class GithubAPIAuth: NSObject {
    static func accessToken() -> String? {
        let keychain = Keychain(service: "net.timothyandrew.GitAmend")
        return keychain["access_token"]
    }
    
    static func refreshToken() -> String? {
        let keychain = Keychain(service: "net.timothyandrew.GitAmend")
        return keychain["refresh_token"]
    }

    static func authSession() -> ASWebAuthenticationSession? {
        guard let clientId = Config.githubClientId(),
              let url = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&redirect_uri=gitamend://callback")
        else { return nil }

        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "gitamend") { url, error in
            // Handle errors + unwrap URL
            guard error == nil, let url = url else {
                // TODO: UI alert
                print("Failed 1")
                return
            }
            
            // Parse URL
            guard let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                let index = items.firstIndex(where: { $0.name == "code" }),
                let code = items[index].value
                else { return }
                        
            // Exchange `code` for a access & refresh tokens
            AF.request("https://github.com/login/oauth/access_token", method: .post, parameters: [
                "client_id": clientId,
                "client_secret": Config.githubClientSecret(),
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

                // Save access & refresh tokens into the system Keychain
                let dict: Dictionary = Dictionary(uniqueKeysWithValues: split)
                let keychain = Keychain(service: "net.timothyandrew.GitAmend")
                keychain["access_token"] =  String(dict["access_token"]!)
                keychain["refresh_token"] = String(dict["refresh_token"]!)
                                
                print("Auth done!")
            }
        }
        
        return session
    }
}
