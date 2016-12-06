//
//  BrowserTableViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/1/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation

class BrowserVideoTableViewCell: UITableViewCell {

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
//        backgroundColor = Styles.Color.Primary
//        postContentView.backgroundColor = Styles.Color.Primary
        let busy = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        busy.color = UIColor.lightGray
        busy.frame = postContentView.bounds
        busy.startAnimating()
        postContentView.addSubview(busy)
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.borderColor = Styles.Color.Primary.cgColor
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.clipsToBounds = true
        
        // Setup video replay
        player = AVPlayer()
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        player.isMuted = true
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = postContentView.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        postContentView.layer.addSublayer(playerLayer)
        playerLayer.isHidden = true
        
//        postImageView.backgroundColor = Styles.Color.Primary
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.isHidden = true

        headingLabel.textColor = UIColor.white
        headingLabel.text = ""
        usernameLabel.text = ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = ""
        headingLabel.text = ""
        avatarImageView.image = nil
        postImageView.image = nil
        postImageView.isHidden = true
        postImageView.contentMode = .scaleAspectFill
        
        // Clear videos
        player.pause()
        player.replaceCurrentItem(with: nil)
//        playerLayer.isHidden = true
    }
    
    // MARK: - Constants
    static let ID = "BrowserVideoTableViewCell"
}