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
        
        static let StoryboardID = SegueID.Storyboard.Sato
        static let RootViewController = SegueID.ViewController.TabBarViewController
//        static let StoryboardID = SegueID.Storyboard.Camera
//        static let RootViewController = SegueID.ViewController.CameraViewController
        
    }
    struct OnLogout {
        static let StoryboardID = SegueID.Storyboard.Main
        static let RootViewController = SegueID.ViewController.LoginViewController
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
            static let Yelp = "Yelp"
            static let VideoComposer = "VideoComposer"
            static let Main = "Main"
            static let Sato = "Sato"
        }
        struct ViewController {
            static let CameraViewController = "CameraViewController"
            static let YelpViewController = "YelpViewController"
            static let VideoComposerViewController = "VideoComposerViewController"
            static let LoginViewController = "LoginViewController"
            static let TabBarViewController = "TabBarViewController"
        }
    }
    struct Images {
        static let avatarDefault = "blank user avatar.jpeg"
        static let audioYellow = "sound-wave-yellow.png"
        static let audio = "sound-wave.png"
        static let location = "location.png"
        static let locationYellow = "location-yellow.png"
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
    init?(string: String?) {
        if let string = string {
            switch string.lowercased() {
            case ContentType.image.string(): self = .image
            case ContentType.video.string(): self = .video
            case ContentType.audio.string(): self = .audio
            case ContentType.template.string(): self = .template
            case ContentType.userMeta.string(): self = .userMeta
            case ContentType.post.string(): self = .post
            default: return nil
            }
        }
        return nil
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
