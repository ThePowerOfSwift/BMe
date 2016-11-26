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
//            for video in videos {
//                print(video.gsURL)
//            }
            self.videos = videos
            self.tableView.reloadData()
        }
        // get array of video object
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
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.identifier, for: indexPath)
        
        let urlString = (videos?[indexPath.row].videoURL)!
        let url = URL(string: urlString)
        let player = AVPlayer(url: url!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = cell.bounds
        cell.layer.addSublayer(playerLayer)
        player.play()
        
        return cell
    }
    
}
