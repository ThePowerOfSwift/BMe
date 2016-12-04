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
import MBProgressHUD

// Deprecated
protocol WatchViewControllerDelegate {
    func getVideo () -> Video?
}

class WatchViewController: UIViewController {
    
    var delegate: WatchViewControllerDelegate?
    var video: Video?
    var url: URL?
    var player: AVPlayer?
    var hud: MBProgressHUD?
    
    @IBOutlet weak var hudView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVPlayer()
        // Show MBProgressHUD when loading video
        hud = MBProgressHUD(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        hudView.addSubview(self.hud!)
        
        // If the state of player changes (AVPlayerStatus becomes readyToPlay), then post notification
        player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
        
        // To call the function that loops a video, post notification when the video ends
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)
        
        video = delegate?.getVideo()
        setupPlayer()
        setupRestaurantLabel()
    }
    
    @IBAction func onTapVideoView(_ sender: UITapGestureRecognizer) {
        if let url = url {
            self.player?.pause()
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if self.player?.status == AVPlayerStatus.readyToPlay {
                self.hud?.hide(animated: true)
                self.player?.play()
            }
        }
    }
    
    func setupPlayer() {
        if let video = video {
            hud?.show(animated: true)
            let urlString = video.videoURL
            url = URL(string: urlString!)
            let playerItem = AVPlayerItem(url: url!)
            player?.replaceCurrentItem(with: playerItem)
            let playerLayer = AVPlayerLayer(player: player)
            let frame: CGRect = CGRect(x: videoView.frame.origin.x, y: videoView.frame.origin.y - 64, width: videoView.frame.width, height: videoView.frame.height)
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            playerLayer.frame = frame
            videoView.layer.addSublayer(playerLayer)
            self.player?.play()

        }
    }

    func setupRestaurantLabel() {
        if let restaurantName = video?.restaurantName {
            restaurantNameLabel.text = restaurantName
        }
    }
    
    func playerItemDidReachEnd(notification: Notification) {
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
    }
}
