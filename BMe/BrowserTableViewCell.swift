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
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!

    // Deprecate- takes too much bandwidth?
    // Video player objects
    var playerLayer: AVPlayerLayer!
    var player: AVPlayer!
    
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
        avatarImageView.layer.borderColor = Styles.Color.Primary.cgColor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.clipsToBounds = true
        
        // Setup video replay
        player = AVPlayer()
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = postContentView.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        postContentView.layer.addSublayer(playerLayer)
        
        postImageView.backgroundColor = Styles.Color.Primary
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        
        headingLabel.textColor = Styles.Color.Secondary
        headingLabel.text = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = ""
        avatarImageView.image = nil
        postImageView.image = nil
        postImageView.isHidden = true
        postImageView.contentMode = .scaleAspectFill
        
        // Clear videos
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
    
    // MARK: - Constants
    static let ID = "BrowserTableViewCell"
}
