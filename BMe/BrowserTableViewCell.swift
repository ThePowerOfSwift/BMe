//
//  BrowserTableViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/1/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation

class BrowserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postContentView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!

    // Video player objects
    var playerLayer: AVPlayerLayer!
    var player: AVPlayer!
    
    var avatarImage: UIImage? {
        didSet {
            avatarImageView.image = avatarImage
        }
    }
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        //avatarImageView.layer.borderColor = style.primarycolor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.clipsToBounds = true
        
        // Set default avatar image
        let defaultAvatarImage = UIImage(named: Constants.User.avatarDefault)
        avatarImage = defaultAvatarImage
        
        // Setup video replay
        player = AVPlayer()
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = postContentView.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        postContentView.layer.addSublayer(playerLayer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImage = nil
        
        // Clear videos
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
    
    // MARK: - Cosntants
    static let ID = "BrowserTableViewCell"
}
