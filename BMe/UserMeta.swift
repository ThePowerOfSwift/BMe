//
//  UserMeta.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserMeta: NSObject {
    let uid: String?
    let avatarURL: URL?
    let timestamp: Date?
    let username: String?
    let raincheck: [String: AnyObject]?
    
    //MARK: - User Database keys
    struct Key {
        static let timestamp = "timestamp"
        static let avatarURL = "avatarURL"
        static let username = "username"
        static let raincheck = "raincheck"
    }
    
    init(_ snapshot: FIRDataSnapshot) {
        uid = snapshot.key
        self.avatarURL = URL(string: snapshot.dictionary[Key.avatarURL] as! String) ?? nil
        self.timestamp = (snapshot.dictionary[Key.timestamp] as? String)?.toDate() ?? nil
        self.username = snapshot.dictionary[Key.username] as? String ?? nil
        self.raincheck = snapshot.dictionary[Key.raincheck] as? [String: AnyObject] ?? nil
    }
}
