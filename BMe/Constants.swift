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
        // static let StoryboardID = "VideoComposition"
        // static let RootViewController = "VideoComposerViewController"
//        static let StoryboardID = "Sato"
//        static let RootViewController = "TabBarNavigationController"
        static let StoryboardID = "ExampleFIRTVC"
        static let RootViewController = "ExampleFIRTVC"
    }
    struct OnLogout {
        static let StoryboardID = "Main"
        static let RootViewController = "LoginViewController"
    }
    struct NotificationKeys {
        static let didSignIn = "onSignInCompleted"
        static let didSignOut = "onSignOutCompleted"
    }
    struct FirebaseStorage {
        static let videos = "videos"
    }
    struct FirebaseDatabase {
        static let videoURLs = "videosURLs"
    }
}

extension CGSize {
    static let portrait = CGSize(width: 720.0, height: 1280.0)
}
