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

class ExampleFIRTVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var videos: [FIRDataSnapshot]! = []
    private var _refHandle: FIRDatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Configure FIR database
        _refHandle = FIRManager.sharedInstance.observeDatabaseObject(named: Constants.FirebaseDatabase.videoURLs, event: .childAdded) { (snapshot) in
            self.videos.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.videos.count-1, section: 0)], with: .automatic)
        }
        // Configure FIR storage
        
    }

    // On dealloc unsubscribe from object observation
    deinit {
        FIRManager.sharedInstance.removeObserverDatabaseObject(named: Constants.FirebaseDatabase.videoURLs, handle: _refHandle)
    }
    
    
    // MARK: - TableView datasource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("item count: \(videos.count)")
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let data = self.videos[indexPath.row].dictionary
        let video = Video(dictionary: data)
        cell.textLabel?.text = video.restaurantName
        
        if let videoURL = video.videoURL {
            print("VideoURL: \(videoURL)")
            if videoURL.isCloudStorage {
            } else if let URL = URL(string: videoURL) {
                cell.imageView?.image = VideoComposition.thumbnail(asset: AVURLAsset(url: URL))
            }
        }
        
        return cell
    }
}
