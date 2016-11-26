//
//  BrowseTestViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/26/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import AVKit
import AVFoundation

class BrowseTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        FIRManager.shared.getVideos { (videos: [Video]) in
            let urlString = (videos[1].videoURL)!
            let url = URL(string: urlString)
            let player = AVPlayer(url: url!)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.frame
            self.view.layer.addSublayer(playerLayer)
            player.play()
            
        }
        
        
//        let urlString = Bundle.main.path(forResource: "test_video", ofType: "mp4")!
//        let url = URL.init(fileURLWithPath: urlString)
//        let video = Video(userId: AppState.shared.currentUser?.uid,
//                          username: AppState.shared.currentUser?.displayName,
//                          templateId: "",
//                          videoURL: url.absoluteString,
//                          gsURL: "",
//                          createdAt: Date())
//        FIRManager.shared.uploadVideo(video: video, completion: {
//        })


        
        // get array
    }
    
    func uploadTestVideo() {
        let urlString = Bundle.main.path(forResource: "test_video", ofType: "mp4")
        
        if let urlString = urlString {
            let url = URL.init(fileURLWithPath: urlString)
            
            // Create a refernce to the file you want to upload
            let testVideoRef = FIRManager.shared.storage.child("videos/test_video.mp4")
            
            // Update
            let uploadTask = testVideoRef.putFile(url, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    
                    // You can get downloadURL here to stream
                    let downloadURL = metadata!.downloadURL()
                    // metadata cannot be uploaded here. it must be somewhere
                    
                    // Store downloadURL to FIRDatabase
                    let databaseRef = FIRManager.shared.database
                    let videosRef = databaseRef.child("video")
                    let key = videosRef.childByAutoId().key
                    let urlString = metadata!.downloadURL()?.absoluteString
                    let video = ["videoURL" : urlString!,
                                 "timestamp" : Date.timeIntervalBetween1970AndReferenceDate.description]
                    let childUpdate = ["/video/\(key)" : video]
                    databaseRef.updateChildValues(childUpdate)
                    
                    // query
                    //                    let query = (self.databaseRef.child("videos")).queryOrdered(byChild: "timestamp")
                    (databaseRef.child("videos")).queryOrdered(byChild: "video").observe(.value, with: { snapshot in
                        for video in snapshot.children {
                            print(video)
                        }
                    })
                }
            })
        }
    }
}
