//
//  FeaturedTableViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/8/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

class FeaturedTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        contentLabel.text = ""
        contentImageView.image = UIImage()
        contentLabel.isHidden = false
        contentImageView.isHidden = false
    }
}
