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
    
    // Model
    var posts: [FIRDataSnapshot]! = []
    fileprivate var _refHandle: FIRDatabaseHandle!
    fileprivate let dbReference = FIRManager.shared.database.child(ContentType.post.objectKey())
    var isFetchingData = false
    let fetchBatchSize = 5
    let cellOffsetToFetchMoreData = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Turn off pushing down scrollview (in TV) but keep content below status bar
//        automaticallyAdjustsScrollViewInsets = false
        navigationController?.isNavigationBarHidden = true
        
        // Put in white reveal
        view.addSubview(WhiteRevealOverlayView(frame: view.bounds))
        
        tableView.delegate = self
        tableView.dataSource = self

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
   
        // Setup player end for loop observation
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        setupDatasource()
    }
    
    func setupDatasource() {
        // Setup datasource
        _refHandle = dbReference.queryLimited(toLast: UInt(3)).observe(.childAdded, with: { (snapshot) in
            self.posts.insert(snapshot, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            //            self.tableView.insertRows(at: [IndexPath(row: self.posts.count - 1, section: 0)], with: .automatic)
        })
    }
    
    // Deregister for notifications
    deinit {
        dbReference.removeObserver(withHandle: _refHandle)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // Loop video
    func playerItemDidReachEnd(_ notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero)
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
        let currentIndex = indexPath.row

        // ------- VIDEO
        if post.contentType == .video {
            let cell = tableView.dequeueReusableCell(withIdentifier: BrowserVideoTableViewCell.ID, for: indexPath) as! BrowserVideoTableViewCell
            cell.tag = currentIndex
            
            // Setup user content
            if let uid = post.uid {
                User.userMeta(uid, block: { (usermeta) in
                    if cell.tag == currentIndex {
                        // Get the avatar if it exists
                        let ref = FIRManager.shared.storage.child(usermeta.avatarURL!.path)
                        cell.avatarImageView.loadImageFromGS(with: ref, placeholderImage: UIImage(named: Constants.Images.avatarDefault))
                        cell.usernameLabel.text = usermeta.username
                    }
                })
            }
            
            // fetch video JSON
            cell.didStartLoadingContent()

            FIRManager.shared.database.child(url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                if cell.tag == currentIndex {
                    //TODO: - TEST
                    cell.headingLabel.text = post.timestamp?.toString() //delete and uncomment three below
                    
                    let video = Video(snapshot.dictionary)
//                    if let meta = video.meta {
//                        let restaurant = Restaurant(dictionary: meta)
//                        cell.headingLabel.text = restaurant.name
//                    }
                    let playerItem = AVPlayerItem(url: video.downloadURL!)
                    cell.player.replaceCurrentItem(with: playerItem)
                    cell.player.automaticallyWaitsToMinimizeStalling = true
                    cell.player.play()
                    cell.playerLayer.isHidden = false
                    
                    cell.didFinishLoadingContent()
                }
            })
            
        // ------- IMAGE
        } else if post.contentType == .image {
            let cell = tableView.dequeueReusableCell(withIdentifier: BrowserImageTableViewCell.ID, for: indexPath) as! BrowserImageTableViewCell
            cell.tag = currentIndex

            // Setup user content
            if let uid = post.uid {
                User.userMeta(uid, block: { (usermeta) in
                    if cell.tag == currentIndex {
                        // Get the avatar if it exists
                        let ref = FIRManager.shared.storage.child(usermeta.avatarURL!.path)
                        cell.avatarImageView.loadImageFromGS(with: ref, placeholderImage: UIImage(named: Constants.Images.avatarDefault))
                        cell.usernameLabel.text = usermeta.username
                    }
                })
            }
            
            // fetch image JSON
            cell.didStartloading()
            FIRManager.shared.database.child(url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                if cell.tag == currentIndex {
                    //TODO: - TEST
                    cell.headingLabel.text = post.timestamp?.toString() //delete and uncomment three below
                    
                    let image = Image(snapshot.dictionary)
//                    if let meta = image.meta {
//                        let restaurant = Restaurant(dictionary: meta)
//                        cell.headingLabel.text = restaurant.name
//                    }
                    let imageRef = FIRManager.shared.storage.child(image.gsURL!.path)
                    cell.postImageView.loadImageFromGS(with: imageRef, placeholderImage: nil)

                    cell.didFinishloading()
                }
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
        print("row at indexPath \(indexPath.row) of \(posts.count - 1)")
        
        //if two rows off, request and block
        if indexPath.row > (posts.count - 1 - cellOffsetToFetchMoreData) {
            fetchMoreDatasource()
        }
    }
    
    func fetchMoreDatasource() {
        if !isFetchingData {
            isFetchingData = true
            let db = FIRManager.shared.database.child(ContentType.post.objectKey())
            let lastKey = posts[posts.count - 1].key
            print("last key '\(lastKey)'")
//            let lastPost = Post(posts[posts.count - 1].dictionary)
//            let lastTimestamp = lastPost.timestamp
//            print("should request from timestamp: \(lastTimestamp)")
            
//            queryStarting(atValue: lastKey).queryLimited(toLast: UInt(fetchBatchSize))
            db.child("timestamp").queryEqual(toValue: "2016-12-06 19:44:44 -0800").observeSingleEvent(of: .value, with:
                { (snapshot) in
                    print(snapshot.value)
                    
                    self.isFetchingData = false
            })
            
        }
    }
    
    // Deprecate or replace - does not pull from Network
    func pullToRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
}
