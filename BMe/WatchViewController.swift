//
//  WatchViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/26/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol WatchViewControllerDelegate {
    func getVideo () -> Video?
}

class WatchViewController: UIViewController {
    
    var delegate: WatchViewControllerDelegate?
    var video: Video?
    var url: URL?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        video = delegate?.getVideo()
        setupPlayer()
        setupRestaurantLabel()
    }
    
    @IBAction func onTapVideoView(_ sender: UITapGestureRecognizer) {
        if let url = url {
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func setupPlayer() {
        if let video = video {
            let urlString = video.videoURL
            url = URL(string: urlString!)
            let player = AVPlayer(url: url!)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.frame
            videoView.layer.addSublayer(playerLayer)
            player.play()
        }
    }

    func setupRestaurantLabel() {
        if let restaurantName = video?.restaurantName {
            restaurantNameLabel.text = restaurantName
        }
    }
}
