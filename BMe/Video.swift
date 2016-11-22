//
//  Video.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

//static let userId = "userId"
//static let templateId = "templateId"
//static let videoURL = "videoURL"
//static let restaurantName = "restaurantName"

class Video: NSObject {
    var userId: String?
    var templateId: String?
    var videoURL: String?
    var restaurantName: String?
    var createdAt: Date?

    init(dictionary: [String:AnyObject]) {
        
        userId = dictionary[Constants.VideoKey.userId] as? String
        templateId = dictionary[Constants.VideoKey.templateId] as? String
        videoURL = dictionary[Constants.VideoKey.videoURL] as? String
        restaurantName = dictionary[Constants.VideoKey.restaurantName] as? String
        
        let createdAtString = dictionary[Constants.VideoKey.createdAt] as? String
        if let createdAtString = createdAtString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = formatter.date(from: createdAtString)
        }
        
    }

}
