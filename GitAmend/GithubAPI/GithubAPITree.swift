//
//  GithubAPITree.swift
//  GitAmend
//
//  Created by Timothy Andrew on 18/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPITree: NSObject, Decodable {
    var tree: [GithubAPIFile]
    let sha: String
    let allowedExtensions: Set = ["md", "json"]
    
    enum CodingKeys: String, CodingKey {
        case tree
        case sha
    }

    func files() -> [GithubAPIFile] {
        self.tree.filter { $0.type == "blob" && allowedExtensions.contains($0.fileExt()) }
    }
    
    func insert(file: GithubAPIFile) {
        self.tree.insert(file, at: 0)
    }
}
