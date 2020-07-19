//
//  GithubAPIFileContents.swift
//  GitAmend
//
//  Created by Timothy Andrew on 18/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPIFileContents: NSObject, Decodable {
    let content: String
    let encoding: String
    let sha: String
}
