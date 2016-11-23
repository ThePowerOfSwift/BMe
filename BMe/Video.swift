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
    
    /** @name Retrieving String Representation */
    
    /**
     * Gets the absolute URL of this Firebase Database location.
     *
     * @return The absolute URL of the referenced Firebase Database location.
     */
//    open func description() -> String
    /**
     * Gets the URL for the Firebase Database location referenced by this FIRDatabaseReference.
     *
     * @return The url of the location this reference points to.
     */
//    open var url: String { get }

    struct Key {
        static let userId = "userId"
        static let templateId = "templateId"
        static let videoURL = "videoURL"
        static let restaurantName = "restaurantName"
        static let createdAt = "createdAt"
    }
    
    var dictionaryFormat: [String: AnyObject?] {
        get {
            return [Video.Key.userId : userId as AnyObject,
                    Video.Key.templateId : templateId as AnyObject,
                    Video.Key.videoURL : videoURL as AnyObject,
                    Video.Key.restaurantName : restaurantName as AnyObject,
                    Video.Key.createdAt : createdAt?.description as AnyObject]
        }
    }

    init(dictionary: [String:AnyObject?]) {
        
        userId = dictionary[Video.Key.userId] as? String
        templateId = dictionary[Video.Key.templateId] as? String
        videoURL = dictionary[Video.Key.videoURL] as? String
        restaurantName = dictionary[Video.Key.restaurantName] as? String
        
        let createdAtString = dictionary[Video.Key.createdAt] as? String
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
