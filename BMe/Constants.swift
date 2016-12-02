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
        static let RootViewController = "TabBarViewController"
//        static let StoryboardID = "CompositionTest"
//        static let RootViewController = "CompositionTestViewController"
//        static let StoryboardID = SegueID.Storyboard.Camera
//        static let RootViewController = SegueID.ViewController.CameraViewController
        
    }
    struct OnLogout {
        static let StoryboardID = "Main"
        static let RootViewController = "LoginViewController"
    }
    struct NotificationKeys {
        static let didSignIn = "onSignInCompleted"
        static let didSignOut = "onSignOutCompleted"
    }
    struct Layout {
        static let itemSpacing: CGFloat = 1.00
        static let thumbnailSize: CGSize = CGSize(width: 93.00, height: 93.00)
        static let inspectionSize: CGSize = CGSize(width: 124.00, height: 124.00)
    }
    struct SegueID {
        struct Storyboard {
            static let Camera = "Camera"
        }
        struct ViewController {
            static let CameraViewController = "CameraViewController"
        }
    }
    struct User {
        static let avatarDefault = "blank user avatar.jpg"
    }
}
