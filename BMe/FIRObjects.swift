//
//  FIRObjects.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/9/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

extension FIR {
    /**
     Firebase object types
     */
    enum object {
        // list object types
        case image, post, video, matchup, userProfile, userPost, like
        
        func key() -> String {
            switch self {
            case .image:
                return "image"
            case .post:
                return "post"
            case .video:
                return "video"
            case .matchup:
                return "matchup"
            case .userProfile:
                return "userProfile"
            case .userPost:
                return "userPost"
            case .like:
                return "like"
            }
        }
        
        func contentType() -> String {
            switch self{
            case .image:
                return "image/jpeg"
            case .video:
                return "video/mp4"
            default:
                return ""
            }
        }
        
        func fileExtension() -> String {
            switch self {
            case .image:
                return ".jpeg"
            case .video:
                return ".mp4"
            default:
                return ""
            }
        }
    }

}
