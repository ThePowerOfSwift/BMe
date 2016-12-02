//
//  BrowserTableViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/1/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class BrowserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postContentView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!

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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        avatarImageView.layer.cornerRadius = 5
        //avatarImageView.layer.borderColor = style.primarycolor
        avatarImageView.layer.borderWidth = 2
        avatarImageView.clipsToBounds = true
    }
}
