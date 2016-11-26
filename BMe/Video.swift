//
//  Video.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class Video: NSObject {
    var userId: String?
    var username: String?
    var templateId: String?
    var videoURL: String?
    var gsURL: String?
    var createdAt: Date?
    var restaurantName: String?
    
    struct Key {
        static let userId = "userId"
        static let username = "username"
        static let templateId = "templateId"
        static let videoURL = "videoURL"
        static let gsURL = "gsURL"
        static let createdAt = "createdAt"
        static let restaurantName = "restaurantName"
    }
    
    var dictionaryFormat: [String: AnyObject?] {
        get {
            return [Key.userId: userId as AnyObject,
                    Key.username: username as AnyObject,
                    Key.templateId: templateId as AnyObject,
                    Key.videoURL: videoURL as AnyObject,
                    Key.gsURL: gsURL as AnyObject,
                    Key.createdAt: createdAt?.description as AnyObject,
                    Key.restaurantName: restaurantName as AnyObject]
        }
    }

    init(dictionary: [String:AnyObject?]) {

        userId = dictionary[Key.userId] as? String
        username = dictionary[Key.username] as? String
        templateId = dictionary[Key.templateId] as? String
        videoURL = dictionary[Key.videoURL] as? String
        gsURL = dictionary[Key.gsURL] as? String
        restaurantName = dictionary[Key.restaurantName] as? String
        
        let createdAtString = dictionary[Video.Key.createdAt] as? String
        if let createdAtString = createdAtString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = formatter.date(from: createdAtString)
        }
    }
    
    init(userId: String?, username: String?, templateId: String?, videoURL: String?, gsURL: String?, createdAt: Date?, restaurantName: String?) {
        self.userId = userId
        self.username = username
        self.templateId = templateId
        self.videoURL = videoURL
        self.gsURL = gsURL
        self.createdAt = createdAt
        self.restaurantName = restaurantName
    }
}


