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
    var templateId: String?
    var videoURL: String?
    var restaurantName: String?
    var createdAt: Date?
    
    var dictionaryFormat: [String:String?] {
        get {
            return [Constants.VideoKey.userId : userId,
                    Constants.VideoKey.templateId : templateId,
                    Constants.VideoKey.videoURL : videoURL,
                    Constants.VideoKey.restaurantName : restaurantName,
                    Constants.VideoKey.createdAt : createdAt?.description]
        }
    }

    init(dictionary: [String:AnyObject?]) {
        
        userId = dictionary[Constants.VideoKey.userId] as? String
        templateId = dictionary[Constants.VideoKey.templateId] as? String
        videoURL = dictionary[Constants.VideoKey.videoURL] as? String
        restaurantName = dictionary[Constants.VideoKey.restaurantName] as? String
        
        let createdAtString = dictionary[Constants.VideoKey.createdAt] as? String
        if let createdAtString = createdAtString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = formatter.date(from: createdAtString)
            //formatter.date(from: Date().toString())
        }
    }
    
    init(userId: String?, templateId: String?, videoURL: String?, restaurantName: String?, createdAt: Date?) {
        self.userId = userId
        self.templateId = templateId
        self.videoURL = videoURL
        self.restaurantName = restaurantName
        //self.createdAt = createdAt
    }

}
//
//var timeSinceNowString: String? {
//    if let timestamp = createdAt {
//        let componentsFormatter = DateComponentsFormatter()
//        componentsFormatter.unitsStyle = .abbreviated
//        componentsFormatter.allowedUnits = [.day, .hour, .minute]
//        
//        return componentsFormatter.string(from: -timestamp.timeIntervalSinceNow)
//    }
//    return nil
//}
//
//var createdAtString: String? {
//    if let createdAt = createdAt {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd/yy, hh:mm"
//        return formatter.string(from: createdAt)
//    }
//    return nil
//}


//accepted
//Date().toString() // convert date to string with userdefined format.

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(from: self)
    }
}
