//
//  AssetCompareCollectionViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/14/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class AssetCompareCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageViewLeading: UIImageView!
    @IBOutlet weak var imageViewTrailing: UIImageView!
    @IBOutlet weak var matchupTitleLabel: UILabel!
    
    /** 
     Model.  OnSet load images from model
     */
    var matchup: Matchup? {
        didSet {
            didSetMatchup()
        }
    }
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /** 
     Common intialization
     */
    func setup() {        
        // Load nib
        let view = Bundle.main.loadNibNamed(keys.nibName, owner: self, options: nil)?.first as! UIView
        
        // Resize to fill container
        view.frame = self.bounds
        view.autoresizingMask = .flexibleHeight
        view.autoresizingMask = .flexibleWidth

        // Add nib view to self
        self.contentView.addSubview(view)

        // Add tap gestures to image views
        let leadingTap = UITapGestureRecognizer(target: self, action: #selector(didTapLeadingImage(_:)))
        let trailingTap = UITapGestureRecognizer(target: self, action: #selector(didTapTrailingImage(_:)))
        imageViewLeading.addGestureRecognizer(leadingTap)
        imageViewTrailing.addGestureRecognizer(trailingTap)
        
    }
    
    /** 
      Populate cell with matchup
     */
    func didSetMatchup() {
        if let matchup = matchup {
            // Set the title
            self.matchupTitleLabel.text = matchup.hashtag
            
            // Get the posts from this match and load the images
            matchup.posts(completion: { (postA, postB) in
                postA.assetURL(completion: { (url) in
                    self.imageViewLeading.loadImageFromGS(url: url, placeholderImage: nil)
                })
                postB.assetURL(completion: { (url) in
                    self.imageViewTrailing.loadImageFromGS(url: url, placeholderImage: nil)
                })
            })
        }
    }

    /** 
     The leading (left) image was tapped
     */
    func didTapLeadingImage(_ sender: UITapGestureRecognizer) {
        if let matchup = matchup {
            matchup.vote(.A)
        }
    }
    
    /**
     The trailing (right) image was tapped
     */
    func didTapTrailingImage(_ sender: UITapGestureRecognizer) {
        if let matchup = matchup {
            matchup.vote(.B)
        }
    }
    
    struct keys {
        static var nibName = "AssetCompareCollectionViewCell"
    }
}
