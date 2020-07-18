//
//  GithubAPIRef.swift
//  GitAmend
//
//  Created by Timothy Andrew on 18/07/20.
//  Copyright © 2020 Timothy Andrew. All rights reserved.
//

import UIKit

class GithubAPIRef: NSObject, Decodable {
    let object: Object
    
    class Object: NSObject, Decodable {
        let sha: String
    }
}
