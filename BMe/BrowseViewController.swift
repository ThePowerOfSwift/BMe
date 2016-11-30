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
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: VideoCell.identifier)
        FIRManager.shared.getVideos { (videos: [Video]) in

            self.videos = videos
            self.tableView.reloadData()
        }
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
        
        // Setup new player item
        let urlString = (videos?[indexPath.row].videoURL)!
        let url = URL(string: urlString)
        let playerItem = AVPlayerItem(url: url!)
        
        // Replace player item in player
        cell.setupPlayer(playerItem: playerItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let watchVC = storyboard?.instantiateViewController(withIdentifier: "WatchViewController") as? WatchViewController
        watchVC?.delegate = self
        self.navigationController?.pushViewController(watchVC!, animated: true)
        print("pushed")
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
