//
//  FirebaseManager.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/21/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FirebaseManager: NSObject {
    
    static let sharedInstance = FirebaseManager(storageRefString: Constants.FirebaseStorage.storageBaseURL)
    var storageVideosRef: FIRStorageReference!
    var databaseVideosURLsRef: FIRDatabaseReference!
        
    init(storageRefString: String) {
        
        // storage
        let storage = FIRStorage.storage()
        let storageRef = storage.reference(forURL: storageRefString)
        storageVideosRef = storageRef.child(Constants.FirebaseStorage.videos) // gs://b-me-e21b7.appspot.com/videos
        
        // database
        let databaseRef = FIRDatabase.database().reference()
        databaseVideosURLsRef = databaseRef.child(Constants.FirebaseDatabase.videoURLs) // https://b-me-e21b7.firebaseio.com/videosURLs
        
        super.init()
    }
    
    func upload(localURL: URL, success: @escaping (_ downloadURL: URL) -> (), failure: @escaping (Error) -> ()) {
        let videoRef = storageVideosRef.child("dummy")
        // "\(uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\((referenceURL as AnyObject).lastPathComponent!)"
        _ = videoRef.putFile(localURL, metadata: nil, completion: {(metadata: FIRStorageMetadata?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let downloadURL = metadata?.downloadURL()
                success(downloadURL!)
            }
        })
    }

}
