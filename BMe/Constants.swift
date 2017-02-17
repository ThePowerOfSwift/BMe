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
    }
    struct OnLogout {
        static let StoryboardID = SegueID.Storyboard.Main
        static let RootViewController = SegueID.ViewController.MainNavViewController
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
            static let Main = "Main"
            static let Login = "Login"
            static let SignUp = "SignUp"
            static let TabBar = "TabBar"
            static let Home = "Home"
        }
        struct ViewController {
            static let MainNavViewController = "MainNavController"
            static let CameraViewController = "CameraViewController"
            static let TabBarViewController = "TabBarViewController"
        }
    }
    
    struct TabBar {
        static let selectedIndex: Int = 0 // Set default vc to camera
        static let selectedTabSize: CGFloat = 70
        static let unselectedTabSize: CGFloat = 50
        static let titleTextFadeAwayAnimationDuration: TimeInterval = 0.5
        static let titleBarBlinkAnimationDuration: TimeInterval = 1
        static let tabbarShowAnimationDuration: TimeInterval = 0.2
        static let titleTextMaxAlpha: CGFloat = 1
        static let titleTextMinAlpha: CGFloat = 0.2
        
        static let tabbarAnimationDuration: TimeInterval = 0.1
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

