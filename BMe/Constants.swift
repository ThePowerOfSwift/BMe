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
        
        static let StoryboardID = "Camera"
        static let RootViewController = "ImageEditingNavigationController"
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
        static let avatarDefault = "blank user avatar.jpeg"
    }
}

enum ContentType {
    case image, video, audio, template, userMeta, post
    func string() -> String {
        switch self {
        case .image:
            return "image/jpeg"
        case .video:
            return "video/mov"
        case .audio:
            return "audio/m4a"
        case .template:
            return "template/videocomposition"
        case .userMeta:
            return ObjectKey.userMeta
        case .post:
            return ObjectKey.post
        }
    }
    func fileExtension() -> String {
        switch self {
        case .image:
            return ".jpeg"
        case .video:
            return ".mov"
        case .audio:
            return ".m4a"
        case .template:
            return ".videocomposition"
        case .userMeta:
            return ObjectKey.userMeta
        case .post:
            return ObjectKey.post
        }
    }
    func objectKey() -> String {
        switch self {
        case .image:
            return ObjectKey.image
        case .video:
            return ObjectKey.video
        case .audio:
            return ObjectKey.audio
        case .template:
            return ObjectKey.template
        case .userMeta:
            return ObjectKey.userMeta
        case .post:
            return ObjectKey.post
        }
    }
}

private struct ObjectKey {
    static let video = "video"
    static let template = "template"
    static let audio = "audio"
    static let image = "image"
    static let post = "post"
    static let userMeta = "userMeta"
}
