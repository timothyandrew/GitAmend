import UIKit

class GithubAPIFile: NSObject, Decodable {
    let path: String
    let type: String
    var sha: String?
    let defaultText: String?
    
    init(path: String, defaultText: String? = nil) {
        self.path = path
        self.type = "blob"
        self.defaultText = defaultText
    }
    
    func shouldTrim(_ s: [Substring]) -> Bool {
        if (s.contains("inbox")) {
            return false
        }
        
        return true
    }
    
    func isPersisted() -> Bool {
        return sha != nil
    }
    
    func prettyFilename(trimPath: Bool = true) -> String {
        var segments = self.path.split(separator: "/")
        segments.removeFirst()
        
        if (trimPath && shouldTrim(segments)) {
            segments = segments.map { s in
                s == segments.last ? s : s.prefix(5)
            }
        }
        
        let filename = segments.joined(separator: "/")
        
        if sha == nil {
            return "[A] \(filename)"
        } else {
            return filename
        }
    }
    
    func fileExt() -> String {
        let filename = self.path.split(separator: "/").last
        let ext = filename?.split(separator: ".").last
        return String(ext ?? "unknown")
    }
    
    func fetchContents(_ repo: String, _ completionHandler: @escaping (_ result: String?, _ error: String?) -> Void) {
        guard let sha = self.sha else {
            let defaultText = self.defaultText ?? "---\ntitle: \"\"\n\n* *\n\n"
            completionHandler(defaultText, nil)
            return
        }
        
        GithubAPI.request("repos/\(repo)/git/blobs/\(sha)", GithubAPIFileContents.self) { response in
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
