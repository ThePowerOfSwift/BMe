//
//  Constants.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/17/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

struct Constants {
    struct OnLogin {
        static let StoryboardID = "Sato"
        static let RootViewController = "TabBarNavigationController"
//        static let StoryboardID = "CompositionTest"
//        static let RootViewController = "CompositionTestViewController"

    }
    struct OnLogout {
        static let StoryboardID = "Main"
        static let RootViewController = "LoginViewController"
    }
    struct NotificationKeys {
        static let didSignIn = "onSignInCompleted"
        static let didSignOut = "onSignOutCompleted"
    }
    
}
