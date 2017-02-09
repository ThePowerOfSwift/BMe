//
//  MatchupCollectionViewCell.swift
//  BMe
//
//  Created by Satoru Sasozaki on 2/6/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class MatchupCollectionViewCell: UICollectionViewCell {
    
    var leftImageView: UIImageView?
    var rightImageView: UIImageView?
    
    var leftLabel: UILabel?
    var rightLabel: UILabel?
    
    /** To scroll colleciton view. */
    var collectionViewDelegate: UICollectionView?
    var homeViewControllerDelegate: HomeViewController?
    
    /** To tell if post has already been voted. To prevent vote the same post multiple times.*/
    var isVoted: Bool = false
    
    /** Stores the current cell's index. Used to calculate the next cell index where collection view scrolls to after being tapped. */
    var itemIndex: Int?
    
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
        
        // Init
        leftImageView = UIImageView()
        rightImageView = UIImageView()
        
        guard let leftImageView = leftImageView, let rightImageView = rightImageView else {
            print("failed to instantiate image view")
            return
        }
        
        leftImageView.isUserInteractionEnabled = true
        rightImageView.isUserInteractionEnabled = true
        
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
        addLabelsToImageViews()
    }
    
    func addLabelsToImageViews() {
        guard let leftImageView = leftImageView, let rightImageView = rightImageView else {
            print("image view is nil")
            return
        }
        leftLabel = UILabel()
        rightLabel = UILabel()
        
        guard let leftLabel = leftLabel, let rightLabel = rightLabel else {
            print("label is nil")
            return
        }
        
        leftImageView.addSubview(leftLabel)
        rightImageView.addSubview(rightLabel)
        
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        leftImageView.addConstraints([
            NSLayoutConstraint(item: leftLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftLabel,
                               attribute: NSLayoutAttribute.centerY,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerY,
                               multiplier: 1.0,
                               constant: 0)
            ])
        
        rightImageView.addConstraints([
            NSLayoutConstraint(item: rightLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightLabel,
                               attribute: NSLayoutAttribute.centerY,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerY,
                               multiplier: 1.0,
                               constant: 0)
            ])
        
    }
    
    /** Shows label to tell which won, fires uploadMatchupResult on Home view controller and scrolls to the next cell. */
    func leftImageViewTapped(sender: UITapGestureRecognizer) {
        guard let collectionViewDelegate = collectionViewDelegate, let homeViewControllerDelegate = homeViewControllerDelegate else {
            print("delegate is nil")
            return
        }
        guard let indexPath = collectionViewDelegate.indexPath(for: self) else {
            print("collection view delegate indexPath is nil")
            return
        }

        
        // Prevent multiple voting
        if isVoted {
            print("This matchup has already been voted. Voting multiple times on the same matchup is not allowed.")
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: 0)
            if nextIndexPath.item < collectionViewDelegate.numberOfItems(inSection: 0) {
                collectionViewDelegate.scrollToItem(at: nextIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            }
            return
        }
        isVoted = true
        
        guard let leftLabel = leftLabel, let rightLabel = rightLabel else {
            print("label is nil")
            return
        }
        
        // upload match up result to server via home view controller
        //homeViewControllerDelegate.uploadMatchupResult(winner: WinnerPost.Left)
        
        
        leftLabel.text = "Win"
        rightLabel.text = "Lose"
        
        self.itemIndex = indexPath.item
        perform(#selector(scrollTo), with: nil, afterDelay: 0.5)
    }
    
    /** Shows label to tell which won, fires uploadMatchupResult on Home view controller and scrolls to the next cell. */
    func rightImageViewTapped(sender: UITapGestureRecognizer) {
        guard let collectionViewDelegate = collectionViewDelegate, let homeViewControllerDelegate = homeViewControllerDelegate else {
            print("delegate is nil")
            return
        }
        guard let indexPath = collectionViewDelegate.indexPath(for: self) else {
            print("collection view delegate indexPath is nil")
            return
        }

        
        // Prevent multiple voting
        if isVoted {
            print("This matchup has already been voted. Voting multiple times on the same matchup is not allowed.")
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: 0)
            if nextIndexPath.item < collectionViewDelegate.numberOfItems(inSection: 0) {
                collectionViewDelegate.scrollToItem(at: nextIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
            }
            return
        }
        isVoted = true
        
        guard let leftLabel = leftLabel, let rightLabel = rightLabel else {
            print("label is nil")
            return
        }
        
        // upload match up result to server via home view controller
        //homeViewControllerDelegate.uploadMatchupResult(winner: WinnerPost.Right)
        
        leftLabel.text = "Lose"
        rightLabel.text = "Win"
        
        self.itemIndex = indexPath.item
        perform(#selector(scrollTo), with: nil, afterDelay: 0.5)
    }
    
    // Can't take argument with any type except id, but id is not available in swift
    // So use property instead
    func scrollTo() {
        guard let collectionViewDelegate = collectionViewDelegate, let itemIndex = itemIndex else {
            print("delegate is nil")
            return
        }
        let nextIndexPath = IndexPath(item: itemIndex + 1, section: 0)
        // Check the bound
        if nextIndexPath.item < collectionViewDelegate.numberOfItems(inSection: 0) {
            collectionViewDelegate.scrollToItem(at: nextIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
    }
}
