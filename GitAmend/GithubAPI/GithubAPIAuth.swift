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

enum AccessTokenFetchMethod {
    case Initial
    case Refresh
}

class GithubAPIAuth: NSObject {
    static func getAccessToken() -> String? {
        let keychain = Keychain(service: "net.timothyandrew.GitAmend")
        return keychain["access_token"]
    }
    
    static func getRefreshToken() -> String? {
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
            
            fetchAccessToken(type: .Initial, code: code)
        }
        
        return session
    }
    
    static func refreshAccessToken() {
        // TODO: Fail gracefully if refresh token doesn't exist
        fetchAccessToken(type: .Refresh, code: getRefreshToken()!)
    }
    
    static func fetchAccessToken(type: AccessTokenFetchMethod, code: String) {
        var params: Dictionary<String, String>
        
        // TODO: Fail gracefully if client id/secret isn't present
        switch type {
        case .Initial:
            params = [
                "client_id": Config.githubClientId()!,
                "client_secret": Config.githubClientSecret()!,
                "code": code,
            ]
        case .Refresh:
            params = [
                "client_id": Config.githubClientId()!,
                "client_secret": Config.githubClientSecret()!,
                "refresh_token": code,
                "grant_type": "refresh_token"
            ]
        }
        
        print(params)
        
        // Exchange `code` for a access & refresh tokens
        AF.request("https://github.com/login/oauth/access_token", method: .post, parameters: params, encoder: URLEncodedFormParameterEncoder.default).responseString { response in
            guard response.response?.statusCode == 200,
                let response = response.value,
                let url = URL(string: response) else {
                // TODO: UI alert
                print("Failed 2")
                return
            }
            
            print(response)
                            
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
            
            guard let access_token = dict["access_token"],
                  let refresh_token = dict["refresh_token"] else {
                // TODO: UI Alert
                print("Failed to fetch access token")
                return
            }

            let keychain = Keychain(service: "net.timothyandrew.GitAmend")
            keychain["access_token"] =  String(access_token)
            keychain["refresh_token"] = String(refresh_token)

            print("Auth done!")
        }
    }
}
