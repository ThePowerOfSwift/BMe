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
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.borderColor = Styles.Color.Tertiary.cgColor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.clipsToBounds = true
        
//        postImageView.backgroundColor = Styles.Color.Primary
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        
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
        postImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Constants
    static let ID = "BrowserImageTableViewCell"
}
