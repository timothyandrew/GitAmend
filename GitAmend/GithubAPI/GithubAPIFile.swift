import UIKit

class GithubAPIFile: NSObject, Decodable {
    let path: String
    let type: String
    
    func prettyFilename() -> String {
        self.path.split(separator: "/").suffix(3).joined(separator: "/")
    }
    
    static func fetchAll(_ repo: String, _ completionHandler: @escaping (_ files: [GithubAPIFile], _ error: String?) -> Void) {
        // TODO: Make branch configurable
        GithubAPI.request("repos/\(repo)/git/ref/heads/master", GithubAPIRef.self) { response in
            let ref: GithubAPIRef? = response.value
            let maybeSha = ref?.object.sha

            guard let sha = maybeSha else {
                completionHandler([], "Failed attempting to fetch the `master` SHA")
                return
            }

            GithubAPI.request("repos/\(repo)/git/trees/\(sha)?recursive=true", GithubAPITree.self) { response in
                let maybeTree: GithubAPITree? = response.value

                guard let tree = maybeTree else {
                    completionHandler([], "Failed attempting to fetch files for SHA \(sha)")
                    return
                }

                completionHandler(tree.files(), nil)
            }
        }
    }
}
