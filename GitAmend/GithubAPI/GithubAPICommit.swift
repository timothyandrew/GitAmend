//
//  GithubAPICommit.swift
//  GitAmend
//
//  Created by Timothy Andrew on 18/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPICommit: NSObject, Decodable {
    let sha: String
    let tree: Tree
    
    class Tree: NSObject, Decodable {
        let sha: String
    }
}
