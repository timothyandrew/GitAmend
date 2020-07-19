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
    let sha: String

    func files() -> [GithubAPIFile] {
        self.tree.filter { $0.type == "blob" }
    }
    
    static func create(baseSha: String, blobSha: String, file: GithubAPIFile, repo: String, _ completion: @escaping (_ tree: GithubAPITree) -> Void) {
        let params: [String: Any] = [
            "base_tree": baseSha,
            "tree": [[
                "path": file.path,
                "mode": "100644",
                "type": "blob",
                "sha": blobSha
            ]]
        ]
        
        GithubAPI.request("repos/\(repo)/git/trees", GithubAPITree.self, method: .Post, params: params) { response in
            let tree: GithubAPITree? = response.value
            completion(tree!)
        }
    }
}
