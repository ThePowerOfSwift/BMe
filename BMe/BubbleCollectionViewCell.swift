//
//  BubbleCollectionViewCell.swift
//  GPUImageObjcDemo
//
//  Created by Satoru Sasozaki on 1/27/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit

class BubbleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    
    // outlet view object will be created after this method. so we can't use view object in here
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
