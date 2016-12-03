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
import MBProgressHUD

class BrowseViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var videos: [Video]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        FIRManager.shared.getVideos { (videos: [Video]) in

            self.videos = videos
            self.tableView.reloadData()
        }
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
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
        
        // Setup player end for loop observation
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // Loop video
    func playerItemDidReachEnd(_ notification: NSNotification) {
        let playerItem = notification.object as! AVPlayerItem
        playerItem.seek(to: kCMTimeZero)
    }
    
    // Deregister for notifications
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
}

extension BrowseViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let videos = videos {
            return videos.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrowserTableViewCell.ID, for: indexPath) as! BrowserTableViewCell
        
        if let video = videos?[indexPath.row] {
            // Setup user content
            let meta = UserMeta(video.userId!, completion: {(usermeta) in
                if let avatarURL = usermeta?.avatarURL {
                    let ref = FIRManager.shared.storage.child(avatarURL.path)
                    cell.avatarImageView.loadImageFromGS(with: ref, placeholderImage: UIImage(named: Constants.User.avatarDefault))
                }
            })
            
            cell.usernameLabel.text = video.username
            
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
    
    func pullToRefresh(refreshControl: UIRefreshControl) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        FIRManager.shared.getVideos { (videos: [Video]) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.videos = videos
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
}

extension BrowseViewController: WatchViewControllerDelegate {
    func getVideo() -> Video? {
        
        return videos?[(tableView.indexPathForSelectedRow?.row)!]
        
    }
}
