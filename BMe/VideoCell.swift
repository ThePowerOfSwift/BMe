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

class VideoCell: UITableViewCell {

    static let identifier = "VideoCell"
    var player: AVPlayer?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        player = AVPlayer()
    }
    override func prepareForReuse() {
        //player = nil
        print("Reused")
    }
    
    func setupPlayer(playerItem: AVPlayerItem) {
        player?.replaceCurrentItem(with: playerItem)
        player?.isMuted = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = contentView.bounds
        contentView.layer.addSublayer(playerLayer)
        
        player?.play()
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
