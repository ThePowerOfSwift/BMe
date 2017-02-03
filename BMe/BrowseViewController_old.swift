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

class BrowseViewController_old: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Model
    var posts: [FIRDataSnapshot]! = []
    fileprivate var _refHandle: FIRDatabaseHandle?
    fileprivate var _refHandleRemove: FIRDatabaseHandle?
    fileprivate let dbReference = FIRManager.shared.database.child(ContentType.post.objectKey()).queryOrdered(byChild: Post.Key.timestamp)
    var isFetchingData = false
    let fetchBatchSize = 5
    let cellOffsetToFetchMoreData = 2
    
    let refreshControl = UIRefreshControl()
    
    var dataSelector = #selector(setupDatasource)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Turn off pushing down scrollview (in TV) but keep content below status bar
//        automaticallyAdjustsScrollViewInsets = false
//        navigationController?.isNavigationBarHidden = true
        
        // Add buffer at top (by setting nav bar clear)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
        // Put in white reveal
        view.addSubview(WhiteRevealOverlayView(frame: view.bounds))
        
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
                
        // Get data
        perform(dataSelector)
    }
    
    func setupDatasource() {
        // Setup datasource
        if let _refHandle = _refHandle {
            dbReference.removeObserver(withHandle: _refHandle)
        }
        self.posts.removeAll()
        tableView.reloadData()
        
        _refHandle = dbReference.queryLimited(toLast: UInt(fetchBatchSize)).observe(.childAdded, with: { (snapshot) in
            // data is returned chronologically, we want the reverse
            self.posts.insert(snapshot, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            
            // stop refresh control if was refreshed
            self.refreshControl.endRefreshing()
        })
    }
    
    func setupRaincheckDB() {
        
        // Observe vales for init loading and for newly added rainchecked posts
        _refHandle = UserProfile.firebasePath(UserAccount.currentUser.uid!).child(UserProfile.Key.raincheck).queryOrdered(byChild: UserProfile.Key.timestamp).observe(.childAdded, with: { (snapshot) in
            print(snapshot.key)
            let postID = snapshot.key 
            FIRManager.shared.fetchPostsWithID([postID], completion: { (snapshots) in
                // data is returned chronologically, we want the reverse
                if snapshots.count > 0 {
                    self.posts.insert(snapshots.first!, at: 0)
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                }
                // stop refresh control if was refreshed
                self.refreshControl.endRefreshing()
            })            
        })
        
        // Observe vales for real time removed rainchecked posts
        _refHandleRemove = UserProfile.firebasePath(UserAccount.currentUser.uid!).child(UserProfile.Key.raincheck).queryOrdered(byChild: UserProfile.Key.timestamp).observe(.childRemoved, with: { (snapshot) in
            // match up the post ID from usermeta with the post ID of
            let removedPostID = snapshot.key
            for snap in self.posts {
                if snap.key == removedPostID {
                    if let foundIndex = self.posts.index(of: snap) {
                        self.posts.remove(at: foundIndex)
                        self.tableView.deleteRows(at: [IndexPath(row: foundIndex, section: 0)], with: .fade)
                        break
                    }
                }
            }
        })
        //stop tvc batching feature
        isFetchingData = true
    }
    
    // Deregister for notifications
    deinit {
        dbReference.removeObserver(withHandle: _refHandle!)
        dbReference.removeObserver(withHandle: _refHandleRemove!)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    //MARK: - Tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = Post(posts![indexPath.row])
        let url = post.url
        let currentIndex = indexPath.row

        print("Processing row \(currentIndex) post stamped \(post.timestamp?.toString()) of type \(post.contentType)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BrowserImageTableViewCell.ID, for: indexPath) as! BrowserImageTableViewCell
        cell.tag = currentIndex
        cell.postID = post.postID
        
        // Setup user content
        if let uid = post.uid {
            UserProfile.get(uid, completion: { (userProfile) in
                if let userProfile = userProfile, cell.postID == post.postID {
                    // Get the avatar if it exists
                    if let avatarURL = userProfile.avatarURL {
                        cell.avatarImageView.loadImageFromGS(url: avatarURL, placeholderImage: UIImage(named: Constants.Images.avatarDefault))
                        cell.usernameLabel.text = userProfile.username
                    }
                    // Setup social links
                    UserProfile.currentUser(completion: { (userProfile) in
                        if let userProfile = userProfile {
                            if cell.tag == currentIndex {
                                // Set raincheck
                                if userProfile.raincheck?[post.postID!] != nil {
                                    cell.raincheckButton.isSelected = true
                                }
                                // Set heart
                                if userProfile.heart?[post.postID!] != nil {
                                    cell.heartButton.isSelected = true
                                }
                            }
                        }
                    })
                }
            })
        }
        
        // fetch image
        FIRManager.shared.database.child(url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
            if cell.postID == post.postID {
                let image = Image(snapshot.dictionary)
                if let meta = image.meta {
                    let restaurant = Restaurant(dictionary: meta)
                    cell.headingLabel.text = restaurant.name
                }
                cell.postImageView.loadImageFromGS(url: image.gsURL!, placeholderImage: nil)
            }
        })

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        print("Did select table row \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //if two rows off, request and block
        if indexPath.row > (posts.count - 1 - cellOffsetToFetchMoreData) {
            fetchMoreDatasource()
        }
    }
    
    func fetchMoreDatasource() {
        if !isFetchingData {
            isFetchingData = true
            
            // Get the "next batch" of posts
            // Request with upper limit on the last loaded post with a lower limit bound by batch size
            let lastPost = Post(posts[posts.count - 1])
            let lastTimestamp = lastPost.timestamp?.toString()
            dbReference.queryEnding(atValue: lastTimestamp).queryLimited(toLast: UInt(fetchBatchSize)).observeSingleEvent(of: .value, with:
                { (snapshot) in
                    
                    // returns posts oldest to youngest, inclusive, so remove last child
                    // and reverse to revert to youngest to oldest order (or reverse and remove first child)
                    var ignoreFirst = true
                    for child in snapshot.children.reversed() {
                        if ignoreFirst { //ignore reference post and add the rest
                            ignoreFirst = false
                        }
                        else {
                            let postSnap = child as! FIRDataSnapshot
                            // append data
                            self.posts.append(postSnap)
                            // load into tv
                            self.tableView.insertRows(at: [IndexPath(row: self.posts.count - 1, section: 0)], with: .automatic)
                        }
                    }
                    self.isFetchingData = false
            })
        }
    }
    
    func pullToRefresh(_ refreshControl: UIRefreshControl) {
        perform(dataSelector)
    }
}
