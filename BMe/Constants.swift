//
//  Constants.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/17/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation

struct Constants {
    struct OnLogin {
        

        static let StoryboardID = SegueID.Storyboard.TabBar
        static let RootViewController = SegueID.ViewController.TabBarViewController

//        static let StoryboardID = SegueID.Storyboard.Camera
//        static let RootViewController = SegueID.ViewController.CameraViewController
        
    }
    struct OnSignUp {
        static let StoryboardID = SegueID.Storyboard.SignUp
        static let RootViewController = SegueID.ViewController.SignUpViewController
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
            static let SignUp = "SignUp"
            static let TabBar = "TabBar"
            static let Browser = "Browser"
            static let PageView = "PageView"
            static let Featured = "Featured"
            static let Account = "Account"
        }
        struct ViewController {
            static let CameraViewController = "CameraViewController"
            static let YelpViewController = "YelpViewController"
            static let VideoComposerViewController = "VideoComposerViewController"
            static let LoginViewController = "LoginViewController"
            static let SignUpViewController = "SignUpNavViewController"//"SignUpViewController"
            static let TabBarViewController = "TabBarViewController"
            static let BrowserViewController = "BrowseViewController"
            static let PageViewController = "PageViewController"
            static let FeaturedViewController = "FeaturedNavigationController"
        }
    }
    
    struct TabBar {
        static let selectedIndex: Int = 1 // Set default vc to camera
        static let selectedTabSize: CGFloat = 70
        static let unselectedTabSize: CGFloat = 50
        static let titleTextFadeAwayAnimationDuration: TimeInterval = 0.5
        static let titleBarBlinkAnimationDuration: TimeInterval = 1
        static let tabbarShowAnimationDuration: TimeInterval = 0.2
        static let titleTextMaxAlpha: CGFloat = 1
        static let titleTextMinAlpha: CGFloat = 0.2
        
        static let tabbarAnimationDuration: TimeInterval = 0.1
    }
    
    struct PageTitles {
        static let cameraPageTitles: [String] = ["camera", "compose"]
        static let browsePageTitles: [String] = ["browse", "featured"]
        static let fontSize: CGFloat = 20
    }
    
    struct Images {
        static let avatarDefault = "blank user avatar.jpeg"
        static let audioYellow = "sound-wave-yellow.png"
        static let audio = "sound-wave.png"
        static let location = "location.png"
        static let locationYellow = "location-yellow.png"
        static let circle = "circle-white.png"
        static let circleYellow = "circle-yellow.png"
        static let home = "home-white.png"
        static let homeYellow = "home-yellow.png"
        static let truffle = "black_truffle.jpg"
        static let error = "error.png"
        static let user = "user-white.png"
        static let userYellow = "user-yellow.png"
        static let hook = "hook.png"
        static let hookYellow = "hook-yellow.png"
        static let hookBlack = "hook-black.png"
        static let hookBlue = "hook-blue.png"
        static let cross = "cross-white.png"
        static let crossYellow = "cross-yellow.png"
        static let next = "nextarrow.png"
        static let nextYellow = "nextarrow-yellow.png"
        static let raincheck = "raincheck.png"
        static let raincheckYellow = "raincheck-yellow.png"
        static let raincheckBlue = "raincheck-blue.png"
        static let raincheckBlack = "raincheck-black.png"
        static let raincheckClosed = "raincheck-closed.png"
        static let raincheckGray = "raincheck-gray.png"
        static let heart = "heart.png"
        static let heartYellow = "heart-yellow.png"
        static let heartBlack = "heart-black.png"
        static let hearBlue = "heart-blue.png"
        static let heartGray = "heart-gray.png"
        static let logout = "logout.png"
    }
    
    struct ImageCompressionAndResizingRate {
        static let compressionRate: CGFloat = 0.005
        static let resizingScale: CGFloat = 0.2
        static let avExportQualityPreset =  AVAssetExportPresetMediumQuality
//AVAssetExportPresetLowQuality
//AVAssetExportPresetMediumQuality
//AVAssetExportPresetHighestQuality
//AVAssetExportPreset640x480
//AVAssetExportPreset960x540
//AVAssetExportPreset1280x720
//AVAssetExportPreset1920x1080
//AVAssetExportPreset3840x2160
////  This export option will produce an audio-only .m4a file with appropriate iTunes gapless playback data
//AVAssetExportPresetAppleM4A
//AVAssetExportPresetPassthrough
    }
    
}

enum ContentType {
    case image, video, audio, template, userMeta, post, restaurantMeta
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
        case .restaurantMeta:
            return ObjectKey.restaurantMeta
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
        case .restaurantMeta:
            return ObjectKey.restaurantMeta
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
        case .restaurantMeta:
            return ObjectKey.restaurantMeta
        }
    }
    init?(string: String) {
        switch string {
        case ContentType.image.string(): self = .image
        case ContentType.video.string(): self = .video
        case ContentType.audio.string(): self = .audio
        case ContentType.template.string(): self = .template
        case ContentType.userMeta.string(): self = .userMeta
        case ContentType.post.string(): self = .post
        case ContentType.restaurantMeta.string(): self = .restaurantMeta
        default: return nil
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
    static let restaurantMeta = "restaurantMeta"
}
