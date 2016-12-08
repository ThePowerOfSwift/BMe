//
//  Post.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/4/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Post: NSObject {
    let contentType: ContentType?
    let timestamp: Date?
    let uid: String?
    let url: URL?
    let postID: String?
    
    struct Key {
        static let contentType = "contentType"
        static let url = "url"
        static let uid = "uid"
        static let timestamp = "timestamp"
        static let postID = "postID"
    }
    
    init(_ snapshot: FIRDataSnapshot) {
        self.postID = snapshot.key
        let dictionary = snapshot.dictionary
        
        if let contentType = dictionary[Key.contentType] as? String {
            self.contentType = ContentType(string: contentType)
        } else { contentType = nil }
        if let urlString = dictionary[Key.url] as? String {
            url = URL(string: urlString)
        } else { url = nil }
        uid = dictionary[Key.uid] as? String
        if let timeString = dictionary[Key.timestamp] as? String {
            timestamp = timeString.toDate()
        } else { timestamp = nil }
    }

    override var description : String {
        return "\tpostID: \(self.postID)" +
        "\n\tuid: \(self.uid)" +
        "\n\tcontent type: \(self.contentType?.string())" +
        "\n\turl path: \(self.url?.path)" +
        "\n\tcreated: \(self.timestamp?.toString())"
    }
}
