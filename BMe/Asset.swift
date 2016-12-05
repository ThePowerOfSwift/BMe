
//
//  Asset.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/4/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase

class Asset: NSObject {
    var contentType: ContentType?
    var downloadURL: String?
    var gsURL: String?
    var uid: String?
    var meta: [String: AnyObject?]?
    
    var _ref: FIRDatabaseHandle?
        
    struct Key {
        static let uid = "uid"
        static let contentType = "contentType"
        static let downloadURL = "downloadURL"
        static let gsURL = "gsURL"
        static let meta = "meta"
    }
    
    init(_ dictionary: [String: AnyObject?]) {
        uid = dictionary[Key.uid] as? String
        contentType = ContentType(string: dictionary[Key.contentType] as? String ?? "")
        downloadURL = dictionary[Key.downloadURL] as? String
        gsURL = dictionary[Key.gsURL] as? String
        meta = dictionary[Key.meta] as? [String: AnyObject?]
    }
}
