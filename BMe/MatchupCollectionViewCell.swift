//
//  MatchupCollectionViewCell.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/14/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

@objc protocol MatchupCollectionViewCellDelegate {
    @objc optional func didSelect(_ sender: MatchupCollectionViewCell)
}

/** 
 Custom CollectionView cell that dispalys two images to be compared.  After the user taps on an image, it sends the result to server and informs the delegate of action.
 */
class MatchupCollectionViewCell: UICollectionViewCell {
    
    static let name = "MatchupCollectionViewCell"
    
    // MARK: Properties
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageViewLeading: UIImageView!
    @IBOutlet weak var imageViewTrailing: UIImageView!
    @IBOutlet weak var matchupTitleLabel: UILabel!
    
    /** 
     Model.  OnSet load model contents into cell
     */
    var matchup: Matchup? {
        didSet {
            didSetMatchup()
        }
    }
    
    /** Delegate */
    var delegate: MatchupCollectionViewCellDelegate?
    
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
     Common intialization called after init
     */
    private func setup() {
        // Load nib
        let view = Bundle.main.loadNibNamed(MatchupCollectionViewCell.name, owner: self, options: nil)?.first as! UIView
        // Resize to fill container
        view.frame = self.bounds
        view.autoresizingMask = .flexibleHeight
        view.autoresizingMask = .flexibleWidth
        // Add nib view to self
        self.contentView.addSubview(view)
        
        // Clear design contents
        imageViewLeading.image = nil
        imageViewTrailing.image = nil
        matchupTitleLabel.text = ""
        
        // Add tap gestures to image views
        let leadingTap = UITapGestureRecognizer(target: self, action: #selector(didTapLeadingImage(_:)))
        let trailingTap = UITapGestureRecognizer(target: self, action: #selector(didTapTrailingImage(_:)))
        imageViewLeading.addGestureRecognizer(leadingTap)
        imageViewTrailing.addGestureRecognizer(trailingTap)
    }
    
    /** 
      Populate cell with matchup
     */
    private func didSetMatchup() {
        if let matchup = matchup, let didVote = matchup.didVote {
            // Set the title
            self.matchupTitleLabel.text = matchup.hashtag
            
            // Get the posts from this match and load the images
            matchup.posts(completion: { (postA, postB) in
                postA.assetStorageURL(completion: { (url) in
                    // TODO: check images are loading for correct cell
                    // if (matchup.ID == self.matchup?.ID)
                    self.imageViewLeading.loadImageFromGS(url: url, placeholderImage: nil)
                })
                postB.assetStorageURL(completion: { (url) in
                    self.imageViewTrailing.loadImageFromGS(url: url, placeholderImage: nil)
                })
            })
            
            if didVote {
                showResults()
            }
        }
        // TODO clear in else
    }

    /** 
     The leading (left) image was tapped
     */
    func didTapLeadingImage(_ sender: UITapGestureRecognizer) {
        if let matchup = matchup {
            matchup.vote(.A)
            didTap()
        }
    }
    
    /**
     The trailing (right) image was tapped
     */
    func didTapTrailingImage(_ sender: UITapGestureRecognizer) {
        if let matchup = matchup {
            matchup.vote(.B)
            didTap()
        }
    }
    
    /** 
     Cell was tapped.  Inform delegate
     */
    private func didTap() {
        showResults()
        
        perform(#selector(didSelect), with: nil, afterDelay: 1.0)
    }
    
    /** 
     User made a selection
     */
    func didSelect() {
        if let delegate = delegate  {
            if let didSelect = delegate.didSelect?(self) {
                didSelect
            }
        }
    }
    
    /** 
     Show voting results
     */
    private func showResults() {
        if let matchup = matchup {
            // Configure imageviews to be "disabled"
            let imageViewAlpha: CGFloat = 0.50
            imageViewLeading.alpha = imageViewAlpha
            imageViewTrailing.alpha = imageViewAlpha
            imageViewLeading.isUserInteractionEnabled = false
            imageViewTrailing.isUserInteractionEnabled = false
            
            //Layover results with bar
            let leadBarView = BarView(parentView: imageViewLeading)
            let trailBarView = BarView(parentView: imageViewTrailing)
            // Tabulate % votes
            let totalCount = matchup.countVoteA + matchup.countVoteB
            let leadPct = totalCount > 0 ? Double(matchup.countVoteA) / Double(totalCount) : 0
            let trailPct = totalCount > 0 ? Double(matchup.countVoteB) / Double(totalCount) : 0
            leadBarView.animateBar(Int(floor(leadPct * 100)))
            leadBarView.showValue()
            trailBarView.animateBar(Int(floor(trailPct * 100)))
            trailBarView.showValue()
        }
    }
    
    /** 
     Resets the cells contents to init state
     */
    override func prepareForReuse() {
        let imageViewAlpha: CGFloat = 1.0
        imageViewLeading.alpha = imageViewAlpha
        imageViewTrailing.alpha = imageViewAlpha
        
        imageViewLeading.isUserInteractionEnabled = true
        imageViewTrailing.isUserInteractionEnabled = true
        
        imageViewLeading.image = nil
        imageViewTrailing.image = nil
        
        // Remove all derived subviews
        for view in imageViewLeading.subviews {
            view.removeFromSuperview()
        }
        for view in imageViewTrailing.subviews {
            view.removeFromSuperview()
        }
        
        matchupTitleLabel.text = ""
    }
    
}
