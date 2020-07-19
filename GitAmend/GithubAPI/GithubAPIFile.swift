import UIKit

class GithubAPIFile: NSObject, Decodable {
    let path: String
    let type: String
    var sha: String
    
    func prettyFilename() -> String {
        self.path.split(separator: "/").suffix(3).joined(separator: "/")
    }
    
    func fetchContents(_ repo: String, _ completionHandler: @escaping (_ result: String?, _ error: String?) -> Void) {
        GithubAPI.request("repos/\(repo)/git/blobs/\(self.sha)", GithubAPIFileContents.self) { response in
            let contents: GithubAPIFileContents? = response.value
            let maybeBase64 = contents?.content
            
            guard let base64 = maybeBase64,
                  let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters),
                  let str = String(data: data, encoding: .utf8) else {
                completionHandler(nil, "Failed to decode base64 contents")
                return
            }
            
            completionHandler(str, nil)
        }
    }
}
