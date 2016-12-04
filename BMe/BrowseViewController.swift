//
//  BrowseViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase

class BrowseViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [FIRDataSnapshot]! = []
    private var _refHandle: FIRDatabaseHandle!
    private let dbReference = FIRManager.shared.database.child(ContentType.post.objectKey())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.estimatedRowHeight = 50
//        tableView.rowHeight = UITableViewAutomaticDimension

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
   
        // Setup player end for loop observation
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Setup datasource
        _refHandle = dbReference.observe(.childAdded, with: { (snapshot) in
            self.posts.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.posts.count - 1, section: 0)], with: .automatic)
        })
        


// YPManager test
/*
var restaurants = [Restaurant]()
_ = YPManager.shared.searchWithTerm("thai", completion: {(response: [Restaurant]?, error: Error?) in
    if let response = response {
        restaurants = response
    }
    for restaurant in restaurants {
        print(restaurant.name!)
    }
})
 */
    }
    
    // Loop video
    func playerItemDidReachEnd(_ notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero)
    }
    
    // Deregister for notifications
    deinit {
        dbReference.removeObserver(withHandle: _refHandle)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

extension BrowseViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrowserTableViewCell.ID, for: indexPath) as! BrowserTableViewCell
        
        if let post = posts?[indexPath.row].dictionary {
            // Setup user content
            
            if let uid = post["uid"] as? String {
                User.userMeta(uid, block: { (usermeta) in
                    // Get the avatar if it exists
                    let ref = FIRManager.shared.storage.child((usermeta.avatarURL?.path)!)
                    cell.avatarImageView.loadImageFromGS(with: ref, placeholderImage: UIImage(named: Constants.Images.avatarDefault))
                     cell.usernameLabel.text = usermeta.username
                })
            }
            
            /*
            // Setup video content
            cell.player.replaceCurrentItem(with: nil)
            
            let url = URL(string: video.videoURL!)
            let playerItem = AVPlayerItem(url: url!)
            cell.player.replaceCurrentItem(with: playerItem)
            cell.player.automaticallyWaitsToMinimizeStalling = true
            cell.player.play()
            cell.player.isMuted = true
             */
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
//        if let video = videos?[indexPath.row] {
//        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func pullToRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
}
