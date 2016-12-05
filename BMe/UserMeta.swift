//
//  UserMeta.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/5/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class UserMeta: NSObject {
    var avatarURL: URL?
    var createdAt: Date?
    var username: String?
    
    //MARK: - User Database keys
    struct Key {
        static let createdAt = "createdAt"
        static let avatarURL = "avatarURL"
        static let username = "username"
    }
    
    init(_ dictionary: [String: AnyObject?]) {
        if let avatar = dictionary[Key.avatarURL] as? String {
            self.avatarURL = URL(string: avatar)
        }
        if let date = dictionary[Key.createdAt] as? String {
            self.createdAt = date.toDate()
        }
        if let username = dictionary[Key.username] as? String {
            self.username = username
        }
    }
}
