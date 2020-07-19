//
//  GithubAPI.swift
//  GitAmend
//
//  Created by Timothy Andrew on 17/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit
import Alamofire

class GithubAPI: NSObject {
    enum Method {
        case Post
        case Get
        case Patch
    }
    
    static func request<T: Decodable>(_ path: String,
                                      _ type: T.Type,
                                      attempt: Int = 0,
                                      method: Method = Method.Get,
                                      params: [String: Any]? = nil,
                                      _ completionHandler: @escaping (_ response: AFDataResponse<T>) -> Void) {
        
        guard let access_token = GithubAPIAuth.getAccessToken() else {
            // TODO: UI alert
            print("Can't access the Github API without an access token")
            return
        }

        let auth: HTTPHeaders = [
            "Authorization": "token \(access_token)"
        ]
        
        let req: DataRequest
            
        switch method {
        case .Post:
            req = AF.request("https://api.github.com/\(path)", method: .post, parameters: params!, encoding: JSONEncoding.default, headers: auth)
        case .Patch:
            req = AF.request("https://api.github.com/\(path)", method: .patch, parameters: params!, encoding: JSONEncoding.default, headers: auth)
        case .Get:
            req = AF.request("https://api.github.com/\(path)", headers: auth)
        }
            
        req.validate().responseDecodable(of: type) { response in
            switch response.result {
            case .success:
                completionHandler(response)
            case let .failure(error):
                guard response.response?.statusCode == 401 else {
                    print("Failed with error \(error); aborting!")
                    return
                }
                
                if (attempt < 2) {
                    print("Got a 401. Attempting to refresh access token and retry; attempts so far: \(attempt)")
                    GithubAPIAuth.refreshAccessToken()
                    request(path, type, attempt: attempt + 1, method: method, params: params, completionHandler)
                } else {
                    print("Failed to refresh access token after \(attempt) retries.")
                }
            }
        }
    }
}
