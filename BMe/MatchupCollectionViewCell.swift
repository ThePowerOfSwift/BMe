//
//  MatchupCollectionViewCell.swift
//  BMe
//
//  Created by Satoru Sasozaki on 2/6/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

enum AnimationViewConstraintConstants: CGFloat {
    case barLabelBottomSpacing = 25
    case barWidth = 6
    case checkMarkLabelSpacing = -10
    case checkMarkImageWidth = 54
    case checkMarkImageHeight = 40
}

enum VoteDirection {
    case Left
    case Right
}

class MatchupCollectionViewCell: UICollectionViewCell {
    
    var leftImageView: UIImageView?
    var rightImageView: UIImageView?
    
    var leftLabel: UILabel?
    var rightLabel: UILabel?
    
    var leftCheckMark: UIImageView?
    var rightCheckMark: UIImageView?
    var leftBar: UIView?
    var rightBar: UIView?
    
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
        
        guard let leftImageView = leftImageView, let rightImageView = rightImageView  else {
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
        addCheckMarkAndRectanglesToImageViews()
        resetAnimationState()
        
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
    
    func addCheckMarkAndRectanglesToImageViews() {
        
        guard let leftImageView = leftImageView, let rightImageView = rightImageView else {
            print("image view is nil")
            return
        }
        
        let image = #imageLiteral(resourceName: "checkmark")
        leftCheckMark = UIImageView.init(image:image)
        rightCheckMark = UIImageView.init(image:image)
        
        leftBar = UIView()
        rightBar = UIView()
        
        guard let  leftCheckMark = leftCheckMark,let rightCheckMark = rightCheckMark, let leftBar = leftBar, let rightBar = rightBar  else {
            print("failed to instantiate checkmarks and rectangle views")
            
            return
        }
        
        leftCheckMark.contentMode = .scaleAspectFit
        rightCheckMark.contentMode = .scaleAspectFit
        
        contentView.addSubview(leftCheckMark)
        contentView.addSubview(leftBar)
        contentView.addSubview(rightCheckMark)
        contentView.addSubview(rightBar)
        
        leftCheckMark.translatesAutoresizingMaskIntoConstraints = false
        rightCheckMark.translatesAutoresizingMaskIntoConstraints = false
        leftBar.translatesAutoresizingMaskIntoConstraints = false
        rightBar.translatesAutoresizingMaskIntoConstraints = false
        
        
        //constraints for left side
        
        //constrain bar off label and off imageview bottom
        //give bar a constant width
        
        contentView.addConstraints([
            NSLayoutConstraint(item: leftBar,
                               attribute: NSLayoutAttribute.top,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftLabel,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.barLabelBottomSpacing.rawValue),
            NSLayoutConstraint(item: leftBar,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftBar,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.barWidth.rawValue),
            NSLayoutConstraint(item: leftBar,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftLabel,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftBar,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            ])
        
        //constrain bar off label and off imageview bottom
        //give checkmark a constant width, height
        //constraint checkmark off label and centerX
        
        contentView.addConstraints([
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftLabel,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkLabelSpacing.rawValue),
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageWidth.rawValue),
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageHeight.rawValue),
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftLabel,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            ])
        
        //constraints for right side
        //same as left
        
        contentView.addConstraints([
            NSLayoutConstraint(item: rightBar,
                               attribute: NSLayoutAttribute.top,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightLabel,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.barLabelBottomSpacing.rawValue),
            NSLayoutConstraint(item: rightBar,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightBar,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.barWidth.rawValue),
            NSLayoutConstraint(item: rightBar,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightLabel,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightBar,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            ])
        
        contentView.addConstraints([
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightLabel,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkLabelSpacing.rawValue),
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageWidth.rawValue),
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageHeight.rawValue),
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightLabel,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
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
        
        //Perform animation before new scroll
        startAnimationState(direction: VoteDirection.Left)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [] , animations: {
            self.endAnimationState()
            
        }, completion: { finished in
        })
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
        
        //Change the size of the bar before aniamtion
        changeBarSizesToPercents()
        
        //Perform animation before new scroll
        startAnimationState(direction: VoteDirection.Right)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [] , animations: {
            self.endAnimationState()
            
        }, completion: { finished in
        })
        
        self.itemIndex = indexPath.item
        perform(#selector(scrollTo), with: nil, afterDelay: 0.5)
    }
    
    func changeBarSizesToPercents() {
        guard let leftBar = leftBar, let rightBar = rightBar else {
            print("bar is nil")
            return
        }
        guard let homeViewControllerDelegate = homeViewControllerDelegate else {
            print("delegate is nil")
            return
        }
        guard let matchup = homeViewControllerDelegate.matchup else {
            print("matchup is nil")
            return
        }
        guard let leftCount = matchup.countVoteA, let rightCount = matchup.countVoteB  else {
            print("counts are nil")
            return
        }
        
        //MARK: Test Which is better to change frame size or Constraint size
        //calculate and change the value of the barlabelbottomspacing constrain
        //        let newDifference = AnimationViewConstraintConstants.barLabelBottomSpacing.rawValue * (1 + percentage)
        //        leftBar.frame.size.height = newFrame
        
        
        //calculate total and percentages
        let total = leftCount + rightCount
        let leftPercentage = leftCount / total
        let rightPercentage = rightCount / total
        let newLeftFrame = leftBar.frame.size.height * CGFloat(leftPercentage)
        let newRightFrame = rightBar.frame.size.height * CGFloat(rightPercentage)
        leftBar.frame.size.height = newLeftFrame
        rightBar.frame.size.height = newRightFrame
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
    
    
    //MARK: Voting Animations
    
    func startAnimationState(direction: VoteDirection) {
        
        guard let  leftCheckMark = leftCheckMark,let rightCheckMark = rightCheckMark, let leftBar = leftBar, let rightBar = rightBar  else {
            print("failed to instantiate checkmarks and rectangle views")
            
            return
        }
        
        leftCheckMark.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        rightCheckMark.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        
        leftCheckMark.alpha = 0.4
        rightCheckMark.alpha = 0.4
        
        leftBar.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        rightBar.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)

        if direction == VoteDirection.Left {
            
            prepareForSelectionAnimation(direction: VoteDirection.Left)
            
        }else {
            prepareForSelectionAnimation(direction: VoteDirection.Right)
        }
       
    }
    
    
    func endAnimationState () {
        
        guard let  leftCheckMark = leftCheckMark,let rightCheckMark = rightCheckMark, let leftBar = leftBar, let rightBar = rightBar  else {
            print("failed to instantiate checkmarks and rectangle views")
            
            return
        }
        
        leftCheckMark.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        rightCheckMark.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        rightCheckMark.alpha = 1.0
        leftCheckMark.alpha = 1.0
        
        leftBar.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        rightBar.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    func prepareForSelectionAnimation(direction: VoteDirection) {
        
        guard let  leftCheckMark = leftCheckMark,let rightCheckMark = rightCheckMark, let leftBar = leftBar, let rightBar = rightBar  else {
            print("failed to instantiate checkmarks and rectangle views")
            
            return
        }
        //unhides subviews
        leftBar.isHidden = false
        rightBar.isHidden = false
        leftBar.backgroundColor = UIColor.red
        rightBar.backgroundColor = UIColor.red
        
        if direction == VoteDirection.Left {
            
            leftCheckMark.isHidden = false
            
        }else {
            rightCheckMark.isHidden = false
        }
    }
    
    
    func resetAnimationState() {
        guard let  leftCheckMark = leftCheckMark,let rightCheckMark = rightCheckMark, let leftBar = leftBar, let rightBar = rightBar  else {
            print("failed to instantiate checkmarks and rectangle views")
            
            return
        }
        //hide subviews
        leftCheckMark.isHidden = true
        rightCheckMark.isHidden = true
        leftBar.isHidden = true
        rightBar.isHidden = true
        
    }
    
    
    
}
