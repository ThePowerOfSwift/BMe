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

// Deprecated
/*
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
        _refHandle = FIRManager.shared.database.child(ContentType.video.objectKey()).observe(.childAdded, with: { (snapshot) in
            self.videos.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.videos.count - 1, section: 0)], with: .automatic)
        })
    }

    // On dealloc unsubscribe from object observation
    deinit {
        FIRManager.shared.database.child(ContentType.video.objectKey()).removeObserver(withHandle: _refHandle)
    }
    
    
    // MARK: - TableView datasource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("item count: \(videos.count)")
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let data = videos[indexPath.row].dictionary
        
        cell.textLabel?.text = data[Video.Key.username] as? String
        
//        if let videoURL = video.videoURL {
//            if let URL = URL(string: videoURL) {
//                cell.imageView?.image = VideoComposition.thumbnail(asset: AVURLAsset(url: URL))
//            }
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = Video(videos[indexPath.row].dictionary)
        let videoURL = URL(string: video.videoURL!)
        
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: videoURL!)
        self.present(playerVC, animated: true, completion: {
            
        })
    }
}
 */
