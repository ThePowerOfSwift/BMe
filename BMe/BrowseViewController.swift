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

        // Turn off pushing down scrollview (in TV) but keep content below status bar
//        automaticallyAdjustsScrollViewInsets = false
        navigationController?.isNavigationBarHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
   
        // Setup player end for loop observation
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Setup datasource
        _refHandle = dbReference.observe(.childAdded, with: { (snapshot) in
            self.posts.insert(snapshot, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        })
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
        let postedObject = posts![indexPath.row].dictionary
        let post = Post(postedObject)
        let url = post.url
        
        if post.contentType == .video {
            let cell = tableView.dequeueReusableCell(withIdentifier: BrowserVideoTableViewCell.ID, for: indexPath) as! BrowserVideoTableViewCell
            
            // Setup user content
            if let uid = post.uid {
                User.userMeta(uid, block: { (usermeta) in
                    // Get the avatar if it exists
                    let ref = FIRManager.shared.storage.child(usermeta.avatarURL!.path)
                    cell.avatarImageView.loadImageFromGS(with: ref, placeholderImage: UIImage(named: Constants.Images.avatarDefault))
                    cell.usernameLabel.text = usermeta.username
                })
            }
            
// fetch video JSON
            FIRManager.shared.database.child(url!.path).observe(.value, with: { (snapshot) in
                let video = Video(snapshot.dictionary)
                if let meta = video.meta {
                    let restaurant = Restaurant(dictionary: meta)
                    cell.headingLabel.text = restaurant.name
                }
                let playerItem = AVPlayerItem(url: video.downloadURL!)
                cell.player.replaceCurrentItem(with: playerItem)
                cell.player.automaticallyWaitsToMinimizeStalling = true
                cell.player.play()
                cell.playerLayer.isHidden = false                
            })
            
        } else if post.contentType == .image {
            let cell = tableView.dequeueReusableCell(withIdentifier: BrowserImageTableViewCell.ID, for: indexPath) as! BrowserImageTableViewCell

            // Setup user content
            if let uid = post.uid {
                User.userMeta(uid, block: { (usermeta) in
                    // Get the avatar if it exists
                    let ref = FIRManager.shared.storage.child(usermeta.avatarURL!.path)
                    cell.avatarImageView.loadImageFromGS(with: ref, placeholderImage: UIImage(named: Constants.Images.avatarDefault))
                    cell.usernameLabel.text = usermeta.username
                })
            }
            
// fetch image JSON
            FIRManager.shared.database.child(url!.path).observe(.value, with: { (snapshot) in
                let image = Image(snapshot.dictionary)
                if let meta = image.meta {
                    let restaurant = Restaurant(dictionary: meta)
                    cell.headingLabel.text = restaurant.name
                }
                let imageRef = FIRManager.shared.storage.child(image.gsURL!.path)
                cell.postImageView.loadImageFromGS(with: imageRef, placeholderImage: nil)
                cell.postImageView.isHidden = false
            })
            
            return cell
        }
        
        return UITableViewCell()
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
