//
//  Video.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class Video: NSObject {
    let contentType: ContentType?
    let downloadURL: String?
    let gsURL: String?
    let uid: String?
    let meta: [String: AnyObject?]?
    
    struct Key {
        static let uid = "uid"
        static let contentType = "contentType"
        static let downloadURL = "downloadURL"
        static let gsURL = "gsURL"
        static let meta = "meta"
    }

    init(_ dictionary: [String: AnyObject?]) {
        uid = dictionary[Key.uid] as? String
        contentType = ContentType(string: dictionary[Key.contentType] as? String)
        downloadURL = dictionary[Key.downloadURL] as? String
        gsURL = dictionary[Key.gsURL] as? String
        meta = dictionary[Key.meta] as? [String: AnyObject?]
        
//        let createdAtString = dictionary[Video.Key.createdAt] as? String
//        createdAt = createdAtString?.toDate()
    }
    
    //    var dictionaryFormat: [String: AnyObject?] {
    //        get {
    //            return [Key.userId: userId as AnyObject,
    //                    Key.username: username as AnyObject,
    //                    Key.templateId: templateId as AnyObject,
    //                    Key.videoURL: videoURL as AnyObject,
    //                    Key.gsURL: gsURL as AnyObject,
    //                    Key.createdAt: createdAt?.description as AnyObject,
    //                    Key.restaurantName: restaurantName as AnyObject]
    //        }
    //    }

}


