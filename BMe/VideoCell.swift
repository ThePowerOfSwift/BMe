//
//  VideoCell.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/26/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MBProgressHUD

class VideoCell: UITableViewCell {

    static let identifier = "VideoCell"
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var hud: MBProgressHUD?
    @IBOutlet weak var hudView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set up AVPlayer
        player = AVPlayer()
        player?.isMuted = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = contentView.bounds
        contentView.layer.addSublayer(playerLayer)
        
        // Show MBProgressHUD when loading video
        hud = MBProgressHUD(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        hudView.addSubview(self.hud!)
        player?.addObserver(self, forKeyPath: "status", options: [], context: nil)

        
    }
    
    override func prepareForReuse() {
        print("Reused")
    }
    
    // Replace player item in player
    func setupPlayer(playerItem: AVPlayerItem) {
        
        self.hud?.show(animated: true)
        // This way, AVPlayer won't overlap when reused
        player?.replaceCurrentItem(with: playerItem)

    }
    
    // http://stackoverflow.com/questions/5401437/knowing-when-avplayer-object-is-ready-to-play
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if self.player?.status == AVPlayerStatus.readyToPlay {
                self.hud?.hide(animated: true)
                //self.player?.play()
            }
        }
    }

}
