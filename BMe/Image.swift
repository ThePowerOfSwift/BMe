//
//  Image.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/30/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class Image: NSObject {
    var userId: String?
    var username: String?
    var url: String?
    var gsURL: String?
    var createdAt: Date?
    
    struct Key {
        static let userId = "userId"
        static let username = "username"
        static let url = "url"
        static let gsURL = "gsURL"
        static let createdAt = "createdAt"
    }
    
    // Should change 'dictionaryFormat' to data
    var dictionaryFormat: [String: AnyObject?] {
        get {
            return [Key.userId: userId as AnyObject,
                    Key.username: username as AnyObject,
                    Key.url: url as AnyObject,
                    Key.gsURL: gsURL as AnyObject,
                    Key.createdAt: createdAt?.description as AnyObject]
        }
    }
    
    init(dictionary: [String:AnyObject?]) {
        
        userId = dictionary[Key.userId] as? String
        username = dictionary[Key.username] as? String
        url = dictionary[Key.url] as? String
        gsURL = dictionary[Key.gsURL] as? String
        createdAt = dictionary[Key.createdAt] as? Date
    }
    
    init(userId: String?, username: String?, url: String?, gsURL: String?, createdAt: Date?, restaurantName: String?) {
        self.userId = userId
        self.username = username
        self.url = url
        self.gsURL = gsURL
        self.createdAt = createdAt
    }
}
