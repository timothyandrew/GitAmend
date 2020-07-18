//
//  GithubAPITree.swift
//  GitAmend
//
//  Created by Timothy Andrew on 18/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPITree: NSObject, Decodable {
    let tree: [GithubAPIFile]
    
    func files() -> [GithubAPIFile] {
        self.tree.filter { $0.type == "blob" }
    }

}
