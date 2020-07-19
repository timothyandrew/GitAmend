//
//  GithubAPIRepository.swift
//  GitAmend
//
//  Created by Timothy Andrew on 19/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPIRepository: NSObject {
    // TODO: Make branch configurable
    static let defaultRefName = "heads/master"
    
    // TODO: private(set) public var
    var path: String
    var ref: GithubAPIRef
    var commit: GithubAPICommit
    var tree: GithubAPITree
    
    init(_ path: String, _ ref: GithubAPIRef, _ commit: GithubAPICommit, _ tree: GithubAPITree) {
        self.path = path
        self.ref = ref
        self.commit = commit
        self.tree = tree        
    }
    
    static func fetch(repo: String, _ completion: @escaping (_ repo: GithubAPIRepository?) -> Void) {
        GithubAPI.request("repos/\(repo)/git/ref/\(defaultRefName)", GithubAPIRef.self) { response in
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
    
    func persistFile(path filePath: String, contents: String, _ completion: @escaping (_ shas: (String, String, String)?) -> Void) {
        print("Creating blob")
        GithubAPI.request("repos/\(self.path)/git/blobs", GithubAPIBlob.self, method: .Post, params: [
            "content": contents,
            "encoding": "utf-8"
        ]) { response in
            let blob: GithubAPIBlob? = response.value
            let maybeBlobSha = blob?.sha
            
            guard let blobSha = maybeBlobSha else {
                completion(nil)
                return
            }
                   
            print("Creating tree")
            GithubAPI.request("repos/\(self.path)/git/trees", GithubAPITree.self, method: .Post, params: [
                "base_tree": self.tree.sha,
                "tree": [[
                    "path": filePath,
                    "mode": "100644",
                    "type": "blob",
                    "sha": blobSha
                ]]
            ]) { response in
                let tree: GithubAPITree? = response.value
                let maybeTreeSha = tree?.sha
                
                guard let treeSha = maybeTreeSha else {
                    completion(nil)
                    return
                }
                
                // TODO: Make this customizable
                let message = "Created at \(NSDate().timeIntervalSince1970) by the GitAmend app."
                
                print("Creating commit")
                GithubAPI.request("repos/\(self.path)/git/commits", GithubAPICommit.self, method: .Post, params: [
                    "message": message,
                    "tree": treeSha,
                    "parents": [self.commit.sha]
                ]) { response in
                    let commit: GithubAPICommit? = response.value
                    let maybeCommitSha = commit?.sha
                    
                    guard let commitSha = maybeCommitSha else {
                        completion(nil)
                        return
                    }
                    
                    print("Creating ref")
                    GithubAPI.request("repos/\(self.path)/git/refs/\(GithubAPIRepository.defaultRefName)", GithubAPIRef.self, method: .Patch, params: [
                        "sha": commitSha,
                        "force": false
                    ]) { response in
                        let maybeRef: GithubAPIRef? = response.value
                        
                        guard let ref = maybeRef else {
                            completion(nil)
                            return
                        }
                        
                        self.ref = ref
                        self.commit = commit!
                        self.tree = tree!
                        
                        print("Created commit with SHA \(commitSha)")
                        completion((blobSha, treeSha, commitSha))
                    }
                }
            }
        }
    }
}
