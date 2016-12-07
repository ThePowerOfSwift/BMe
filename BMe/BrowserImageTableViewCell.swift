//
//  BrowserImageTableViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation

class BrowserImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postContentView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

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
        avatarImageView.layer.borderColor = Styles.Avatar.borderColor.cgColor
        avatarImageView.layer.borderWidth = Styles.Avatar.borderWidth
        avatarImageView.clipsToBounds = true
        
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        
        headingLabel.textColor = Styles.Color.Secondary
        headingLabel.text = ""
        headingLabel.textColor = Styles.Color.Primary
        usernameLabel.text = ""
        
        // Activity indicator
        activityIndicator.color = UIColor.lightGray
        activityIndicator.frame = postContentView.bounds
        postContentView.addSubview(activityIndicator)
    }
    
    func didStartloading() {
        activityIndicator.startAnimating()
    }
    
    func didFinishloading() {
        activityIndicator.stopAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = ""
        headingLabel.text = ""
        avatarImageView.image = nil
        postImageView.image = nil
        postImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Constants
    static let ID = "BrowserImageTableViewCell"
}
