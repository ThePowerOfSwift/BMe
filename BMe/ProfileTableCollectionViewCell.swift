//
//  ProfileTableCollectionViewCell.swift
//  BMe
//
//  Created by parry on 2/2/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class ProfileTableCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postContentView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    
    // Model
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
        tag = 0
        postID = ""
    }
    
    // MARK: - Raincheck button datasource
    func postID(_ sender: UIButton) -> String {
        print("Returning ID \(postID) to button")
        return postID
    }

}
