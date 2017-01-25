//
//  AppState.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import Foundation
import Firebase


// TODO: DEPRECATE
class AppState: NSObject {
    
    static let shared = AppState()
    
    // Hide singleton initializer
    private override init() {
        super.init()
    }
}

