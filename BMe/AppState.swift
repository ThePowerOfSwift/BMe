//
//  AppState.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import Foundation
import Firebase

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    // Hide singleton initializer
    private override init() {
        super.init()
    }
    
    var signedIn = false
    var displayName: String?
    var photoURL: URL?
    var userID: String?
}
