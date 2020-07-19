//
//  GithubAPIRepository.swift
//  GitAmend
//
//  Created by Timothy Andrew on 19/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPIRepository: NSObject {
    let path: String
    let ref: GithubAPIRef
    let commit: GithubAPICommit
    let tree: GithubAPITree
    
    init(_ path: String, _ ref: GithubAPIRef, _ commit: GithubAPICommit, _ tree: GithubAPITree) {
        self.path = path
        self.ref = ref
        self.commit = commit
        self.tree = tree        
    }
    
    static func fetch(repo: String, _ completion: @escaping (_ repo: GithubAPIRepository?) -> Void) {
        // TODO: Make branch configurable
        GithubAPI.request("repos/\(repo)/git/ref/heads/master", GithubAPIRef.self) { response in
            let ref: GithubAPIRef? = response.value
            let maybeSha = ref?.object.sha

            guard let sha = maybeSha else {
                completion(nil)
                return
            }
            
            GithubAPI.request("repos/\(repo)/git/commits/\(sha)", GithubAPICommit.self) { response in
                let commit: GithubAPICommit? = response.value
                let maybeTreeSha = commit?.tree.sha
                
                guard let treeSha = maybeTreeSha else {
                    completion(nil)
                    return
                }
                
                GithubAPI.request("repos/\(repo)/git/trees/\(treeSha)?recursive=true", GithubAPITree.self) { response in
                    let maybeTree: GithubAPITree? = response.value

                    guard let tree = maybeTree else {
                        completion(nil)
                        return
                    }

                    let repo = GithubAPIRepository(repo, ref!, commit!, tree)
                    completion(repo)
                }
            }
        }
    }
}
