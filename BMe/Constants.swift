//
//  Constants.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/17/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

struct Constants {
    struct VideoCompositionKey {
        static let videoURLs = "videosURLs"
        static let audioURL = "audioURL"
        static let name = "name"
        static let templateID = "id"
    }
    struct CGSizes {
        static let portrait = CGSize(width: 720.0, height: 1280.0)
    }
    struct VideoCompositionStoryboard {
        static let ID = "VideoComposition"
        static let videoCompositionViewController = "VideoCompositionViewController"
    }
    struct OnLogin {
        static let StoryboardID = "VideoComposition"
        static let RootViewController = "VideoComposerViewController"
    }
    struct OnLogout {
        static let StoryboardID = "Main"
        static let RootViewController = "LoginViewController"
    }
    struct NotificationKeys {
        static let didSignIn = "onSignInCompleted"
        static let didSignOut = "onSignOutCompleted"
    }
    struct VideoKey {
        static let userId = "userId"
        static let templateId = "templateId"
        static let videoURL = "videoURL"
        static let restaurantName = "restaurantName"
        static let createdAt = "createdAt"
    }
    struct FirebaseStorage {
        static let storageBaseURL = "gs://b-me-e21b7.appspot.com"
        static let videos = "videos"
    }
    struct FirebaseDatabase {
        static let databaseBaseURL = "https://b-me-e21b7.firebaseio.com/"
        static let videoURLs = "videosURLs"
    }
}
