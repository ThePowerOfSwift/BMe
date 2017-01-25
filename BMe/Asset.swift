
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
    var downloadURL: URL?
    var gsURL: URL?
    var uid: String?
    var meta: [String: AnyObject?]?
    
//    var _ref: FIRDatabaseHandle?
        
    struct Key {
        static let uid = "uid"
        static let contentType = "contentType"
        static let downloadURL = "downloadURL"
        static let gsURL = "gsURL"
        static let meta = "meta"
    }
    
    // TODO: convert to Snapshot instead of dictionary
    init(_ dictionary: [String: AnyObject?]) {
        uid = dictionary[Key.uid] as? String
        contentType = ContentType(string: dictionary[Key.contentType] as? String ?? "")
        if let downloadURLString = dictionary[Key.downloadURL] as? String {
            downloadURL = URL(string: downloadURLString)
        }
        if let gsURLString = dictionary[Key.gsURL] as? String {
            gsURL = URL(string: gsURLString)
        }
        meta = dictionary[Key.meta] as? [String: AnyObject?]        
    }
}
