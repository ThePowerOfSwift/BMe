//
//  MatchupCollectionViewCell.swift
//  BMe
//
//  Created by Satoru Sasozaki on 2/6/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit


enum VoteDirection {
    case Left
    case Right
}

class MatchupCollectionViewCell: UICollectionViewCell {
    
    var leftImageView: UIImageView = UIImageView()
    var rightImageView: UIImageView = UIImageView()
    
    var leftLabel: UILabel?
    var rightLabel: UILabel?
    
    var leftCheckMark: UIImageView?
    var rightCheckMark: UIImageView?
    var leftBar: UIView?
    var rightBar: UIView?
    
    var leftLabelText = ""
    var rightLabelText = ""
    
    /** To scroll colleciton view. */
    var collectionViewDelegate: UICollectionView?
    
    /** To tell if post has already been voted. To prevent vote the same post multiple times.*/
    var isVoted: Bool = false
    
    /** Stores the current cell's index. Used to calculate the next cell index where collection view scrolls to after being tapped. */
    var itemIndex: Int?
    
    var hashtagLabel: UILabel = UILabel()
    
    var matchup: Matchup?
    
    var bar: BarView!
    
    var leftPercentage = 0
    var rightPercentage = 0
    
    var tapCount = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        initalSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initalSetup() {
        self.isUserInteractionEnabled = true
        
        bar = BarView(parentView: self)
        leftImageView.isUserInteractionEnabled = true
        rightImageView.isUserInteractionEnabled = true
        
        leftImageView.contentMode = UIViewContentMode.scaleAspectFit
        rightImageView.contentMode = UIViewContentMode.scaleAspectFit
                
        // Initialization code
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(leftImageViewTapped(sender:)))
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(rightImageViewTapped(sender:)))
        
        // add gesture recognizer
        leftImageView.addGestureRecognizer(leftTapGesture)
        rightImageView.addGestureRecognizer(rightTapGesture)
        
        // Color
        leftImageView.backgroundColor = UIColor.lightGray
        rightImageView.backgroundColor = UIColor.lightGray
        
        // Autolayout
        contentView.addSubview(leftImageView)
        contentView.addSubview(rightImageView)
        
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            NSLayoutConstraint(item: leftImageView,
                               attribute: NSLayoutAttribute.top,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftImageView,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftImageView,
                               attribute: NSLayoutAttribute.leading,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.leading,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftImageView,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: contentView.frame.width/2)
            ])
        
        contentView.addConstraints([
            NSLayoutConstraint(item: rightImageView,
                               attribute: NSLayoutAttribute.top,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightImageView,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightImageView,
                               attribute: NSLayoutAttribute.trailing,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.trailing,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightImageView,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: contentView.frame.width/2)
            ])
        addhashtagLabelToContentView()
    }
    
    
    func addhashtagLabelToContentView() {

        hashtagLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hashtagLabel)
        contentView.addConstraints([
            NSLayoutConstraint(item: hashtagLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: hashtagLabel,
                               attribute: NSLayoutAttribute.top,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: contentView,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: 10),
            NSLayoutConstraint(item: hashtagLabel,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: 50),
            
            NSLayoutConstraint(item: hashtagLabel,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: 100)
            ])
        hashtagLabel.backgroundColor = UIColor.white
        hashtagLabel.textAlignment = .center
    }
    
    /** Shows label to tell which won, fires uploadMatchupResult on Home view controller and scrolls to the next cell. */
    func leftImageViewTapped(sender: UITapGestureRecognizer) {
        
        showResult(which: .Left)
        perform(#selector(scrollTo), with: nil, afterDelay: 0.5)

        if tapCount == 0 {
            bar.animateBar(leftPercentage)
            bar.showValue()
        }
        
        tapCount += 1
    }
    
    /** Shows label to tell which won, fires uploadMatchupResult on Home view controller and scrolls to the next cell. */
    func rightImageViewTapped(sender: UITapGestureRecognizer) {

        showResult(which: .Right)
        perform(#selector(scrollTo), with: nil, afterDelay: 0.5)

        if tapCount == 0 {
            bar.animateBar(rightPercentage)
            bar.showValue()
        }
        
        tapCount += 1
    }
    
    private func showResult(which: VoteDirection) {
        guard let matchup = matchup else {
            print("matchup is nil")
            return
        }
        
        guard let hashtag = matchup.hashtag, let countVoteA = matchup.countVoteA, let countVoteB = matchup.countVoteB  else {
            print("count of vote nil")
            print("hashtag nil")
            return
        }
        
        var leftCount:Double = 0
        var rightCount:Double = 0
        if which == .Left {
            matchup.vote(Matchup.voteFor.A)
            print("matchup ID: \(matchup.ID), hashtag: \(hashtag), left is voted.")
            print("Before, A: \(countVoteA), B: \(countVoteB).")
            leftCount = Double(countVoteA)+1
            rightCount = Double(countVoteB)
        } else {
            matchup.vote(Matchup.voteFor.B)
            print("matchup ID: \(matchup.ID), hashtag: \(hashtag), right is voted.")
            print("Before, A: \(countVoteA), B: \(countVoteB).")
            leftCount = Double(countVoteA)
            rightCount = Double(countVoteB)+1
        }
        print("After, A: \(leftCount), B: \(rightCount).")
        
        let totalCount = leftCount + rightCount
        let double1: Double = leftCount / totalCount
        let double2: Double = rightCount / totalCount

        leftPercentage = Int((leftCount / totalCount) * Double(100))
        rightPercentage = Int((rightCount / totalCount) * Double(100))
    }
    
    // Can't take argument with any type except id, but id is not available in swift
    // So use property instead
    internal func scrollTo() {
        guard let collectionViewDelegate = collectionViewDelegate else {
            print("delegate is nil")
            return
        }
        guard let currentIndexPath = collectionViewDelegate.indexPath(for: self) else {
            print("currentIndexPath is nil")
            return
        }
        
        let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: 0)
        // Check the bound
        if nextIndexPath.item < collectionViewDelegate.numberOfItems(inSection: 0) {
            collectionViewDelegate.scrollToItem(at: nextIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    override func prepareForReuse() {
        leftImageView.image = nil
        rightImageView.image = nil
        hashtagLabel.text = ""
        bar.reset()
        tapCount = 0

    }
    
}
