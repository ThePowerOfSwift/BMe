//
//  TestVideosViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import AVKit

class VideosListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var videos: [FIRDataSnapshot]! = []
    private var _refHandle: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Configure FIR database
        _refHandle = FIRManager.shared.observeDatabaseObject(named: FIRManager.ObjectKey.video, event: .childAdded) { (snapshot) in
            self.videos.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.videos.count - 1, section: 0)], with: .automatic)
        }
        // Configure FIR storage
        
    }

    // On dealloc unsubscribe from object observation
    deinit {
        FIRManager.shared.unobserveDatabaseObject(named: FIRManager.ObjectKey.video, handle: _refHandle)
    }
    
    
    // MARK: - TableView datasource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("item count: \(videos.count)")
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let data = videos[indexPath.row].dictionary
        let video = Video(dictionary: data)
        
        cell.textLabel?.text = video.username!
        
        if let videoURL = video.videoURL {
            print("VideoURL: \(videoURL)")
            if videoURL.isCloudStorage {
                FIRManager.shared.storage(url: videoURL).downloadURL(completion: { (url: URL?, error: Error?) in
                    if let error = error {
                        print("Error retrieving from GStorage, aborting: \(error.localizedDescription)")
                        return
                    }
                    video.videoURL = url?.absoluteString
                    cell.imageView?.image = VideoComposition.thumbnail(asset: AVURLAsset(url: url!))
                })
            } else if let URL = URL(string: videoURL) {
                cell.imageView?.image = VideoComposition.thumbnail(asset: AVURLAsset(url: URL))
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = Video(dictionary: videos[indexPath.row].dictionary)
        var videoURL = URL(string: video.videoURL!)
        
        if (videoURL?.absoluteString.isCloudStorage)! {
            FIRManager.shared.storage(url: video.videoURL!).downloadURL(completion: { (url: URL?, error: Error?) in
                videoURL = url
                
                let playerVC = AVPlayerViewController()
                playerVC.player = AVPlayer(url: videoURL!)
                self.present(playerVC, animated: true, completion: {
                    
                })
            })
        }
    }
}
