//
//  GithubAPIBlob.swift
//  GitAmend
//
//  Created by Timothy Andrew on 18/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPIBlob: NSObject, Decodable {
    let url: String
    let sha: String
    
    static func create(content: String, repo: String, _ completion: @escaping (_ blob: GithubAPIBlob) -> Void) {

    }
}
