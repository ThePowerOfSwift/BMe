//
//  BrowserImageTableViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/6/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import AVFoundation

class BrowserImageTableViewCell: UITableViewCell, RainCheckButtonDatasource {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postContentView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var raincheckButton: RainCheckButton!
    var postID: String!
    
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    // MARK: - Constants
    static let ID = "BrowserImageTableViewCell"
    
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
        raincheckButton.datasource = self
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.borderColor = Styles.Avatar.borderColor.cgColor
        avatarImageView.layer.borderWidth = Styles.Avatar.borderWidth
        avatarImageView.clipsToBounds = true
        
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        
        headingLabel.textColor = Styles.Color.Secondary
        headingLabel.textColor = Styles.Color.Primary
        
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
    
    
    // MARK: - Raincheck button datasource
    func postID(_ forRainCheckButton: RainCheckButton) -> String {
        return postID
    }
}
