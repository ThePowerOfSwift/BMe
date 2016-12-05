//
//  Post.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/4/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class Post: NSObject {
    let contentType: ContentType?
    let url: URL?
    let uid: String?
    
    struct Key {
        static let contentType = "contentType"
        static let url = "url"
        static let uid = "uid"
    }
    
    init(_ dictionary: [String: AnyObject?]) {
        if let contentType = dictionary[Key.contentType] as? String {
            self.contentType = ContentType(string: contentType)
        } else { contentType = nil }
        if let urlString = dictionary[Key.url] as? String {
            url = URL(string: urlString)
        } else { url = nil }
        uid = dictionary[Key.uid] as? String
    }
    
    override var description : String {
        return "\tuid: \(self.uid)" +
        "\n\tcontent type: \(self.contentType?.string())" +
        "\n\turl path: \(self.url?.path)"
    }
}
