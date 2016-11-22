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
    var databaseVideosRef: FIRDatabaseReference!
        
    private init(storageRefString: String) {
        
        // storage
        let storage = FIRStorage.storage()
        let storageRef = storage.reference(forURL: storageRefString)
        storageVideosRef = storageRef.child(Constants.FirebaseStorage.videos) // gs://b-me-e21b7.appspot.com/videos
        
        // database
        let databaseRef = FIRDatabase.database().reference()
        databaseVideosRef = databaseRef.child(Constants.FirebaseDatabase.videoURLs) // https://b-me-e21b7.firebaseio.com/videosURLs
        
        super.init()
    }
    
    // upload takes
    // - a local URL of a video to upload
    // - a success closure that receives its download url
    // - a failure closure
    func upload(localURL: URL, success: @escaping (_ downloadURL: URL) -> (), failure: @escaping (Error) -> ()) {
        //let childRef = "\(AppState.sharedInstance.userID)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(localURL)"
        let childRef = "\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(localURL.lastPathComponent)"
        let videoRef = storageVideosRef.child(childRef)
        let uploadTask = videoRef.putFile(localURL, metadata: nil, completion: {(metadata: FIRStorageMetadata?, error: Error?) in
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let downloadURL = metadata?.downloadURL()
                success(downloadURL!)
            }
        })
        
        
        // if it is user's video
        
        // if it is template video
    }
    
    // saveVideoToDatabase 
    // - takes a Video object
    // - generates its unique id for its path
    // - generates the dictionary of the video
    // - upload the unique id as key, the dictionary as value
    func saveVideoToDatabase(video: Video) {
        
        let key = databaseVideosRef.childByAutoId().key
        let dictionary = video.dictionaryFormat
        let childUpdate = [key : dictionary]
        databaseVideosRef.updateChildValues(childUpdate)
        
    }
    
    // getVideos takes
    // - a success closure that takes
    func getVideos(success: @escaping ([Video]) -> (), failure: @escaping (Error) -> ()) {
        databaseVideosRef.queryLimited(toLast: 20).queryOrdered(byChild: Constants.VideoKey.createdAt).observe(.value, with: {(snapshot) in

            var videos = [Video]()
            
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                let dictionary = child.value as! [String:AnyObject?]
                let video = Video(dictionary: dictionary)
                videos.append(video)
            }

            success(videos)
        })
        
    }
}
