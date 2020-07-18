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
    static func request<T: Decodable>(_ path: String, _ type: T.Type, _ attempt: Int = 0, _ completionHandler: @escaping (_ response: AFDataResponse<T>) -> Void) {
        // TODO: Degrade if `accessToken` isn't available
        let auth: HTTPHeaders = [
            "Authorization": "token \(GithubAPIAuth.getAccessToken()!)"
        ]

        AF.request("https://api.github.com/\(path)", headers: auth).validate().responseDecodable(of: type) { response in
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
                    request(path, type, attempt + 1, completionHandler)
                } else {
                    print("Failed to refresh access token after \(attempt) retries.")
                }
            }
        }
    }
}
