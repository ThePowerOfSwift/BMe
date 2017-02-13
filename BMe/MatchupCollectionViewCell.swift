//
//  MatchupCollectionViewCell.swift
//  BMe
//
//  Created by Satoru Sasozaki on 2/6/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit


struct AnimationViewConstraintConstants {
    static let barWidth: CGFloat = 6
    static let checkMarkLabelSpacing: CGFloat = -10
    static let checkMarkImageWidth: CGFloat = 54
    static let checkMarkImageHeight: CGFloat = 40
    static let winLabelHeight: CGFloat = 20.5
    static var barLabelSpacing: CGFloat = -25
    
    static var leftBarCalculatedHeight: CGFloat = 0
    static var rightBarCalculatedHeight: CGFloat = 0
    
    
}

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
    
    var leftResultLabel: UILabel = UILabel()
    var rightResultLabel: UILabel = UILabel()
    
    var hashtagLabel: UILabel = UILabel()
    
    var matchup: Matchup?
    
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
        addResultLabelToImageViews()
        addhashtagLabelToContentView()
    }
    
    func addResultLabelToImageViews() {
        
        leftImageView.addSubview(leftResultLabel)
        rightImageView.addSubview(rightResultLabel)
        
        leftResultLabel.translatesAutoresizingMaskIntoConstraints = false
        rightResultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        leftImageView.addConstraints([
            NSLayoutConstraint(item: leftResultLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftResultLabel,
                               attribute: NSLayoutAttribute.centerY,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerY,
                               multiplier: 1.0,
                               constant: 0),
            
            NSLayoutConstraint(item: leftResultLabel,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: 50),
            
            NSLayoutConstraint(item: leftResultLabel,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: 100)
            
            ])
        
        rightImageView.addConstraints([
            NSLayoutConstraint(item: rightResultLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightResultLabel,
                               attribute: NSLayoutAttribute.centerY,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerY,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightResultLabel,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: 50),
            
            NSLayoutConstraint(item: rightResultLabel,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: 100)
            ])
        
        leftResultLabel.backgroundColor = UIColor.white
        rightResultLabel.backgroundColor = UIColor.white
        leftResultLabel.textAlignment = .center
        rightResultLabel.textAlignment = .center
        leftResultLabel.text = "left"
        rightResultLabel.text = "right"
        leftResultLabel.isHidden = true
        rightResultLabel.isHidden = true
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
        guard let didVote = matchup?.didVote else {
            print("didVote or matchup is nil")
            return
        }
        
        print("didVote: \(didVote)")
//        if !didVote {
//            showResult(which: .Left)
//            perform(#selector(scrollTo), with: nil, afterDelay: 0.5)
//        }

        showResult(which: .Left)
        perform(#selector(scrollTo), with: nil, afterDelay: 0.5)
        
//        leftResultLabel.isHidden = false
//        rightResultLabel.isHidden = false
//        
//        let leftCount: Double = Double(homeViewControllerDelegate.matchup!.countVoteA!)
//        let rightCount: Double = Double(homeViewControllerDelegate.matchup!.countVoteB!+1)
//        let totalCount = leftCount + rightCount
//        let leftPercentage: Double = leftCount / totalCount
//        let rightPercentage: Double = rightCount / totalCount
//        leftResultLabel.text = String(format: "%.0f", leftPercentage*100) + "%"
//        rightResultLabel.text = String(format: "%.0f", rightPercentage*100) + "%"
//        
//        //cast vote
//        homeViewControllerDelegate.uploadMatchupResult(winner: WinnerPost.Left)
        
        
        //leftLabelText = "Win"
        //rightLabelText = "Lose"

        //Change the size of the bar before aniamtion
//        createVotingAnimationSubviews()
        
        //Perform animation before new scroll
//        startAnimationState(direction: VoteDirection.Left)
//        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [] , animations: {
//            self.endAnimationState()
//            
//        }, completion: { finished in
//        })

    }
    
    /** Shows label to tell which won, fires uploadMatchupResult on Home view controller and scrolls to the next cell. */
    func rightImageViewTapped(sender: UITapGestureRecognizer) {
        guard let didVote = matchup?.didVote else {
            print("didVote or matchup is nil")
            return
        }
        print("didVote: \(didVote)")
//        if !didVote {
//            showResult(which: .Right)
//            perform(#selector(scrollTo), with: nil, afterDelay: 0.5)
//        }

        showResult(which: .Right)
        perform(#selector(scrollTo), with: nil, afterDelay: 0.5)
        //Change the size of the bar before aniamtion
        //createVotingAnimationSubviews()
        
//        Perform animation before new scroll
//        startAnimationState(direction: VoteDirection.Right)
//        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [] , animations: {
//            self.endAnimationState()
//            
//        }, completion: { finished in
//        })
        
    }
    
    private func showResult(which: VoteDirection) {
        guard let matchup = matchup else {
            print("matchup is nil")
            return
        }
        leftResultLabel.isHidden = false
        rightResultLabel.isHidden = false
        
        var leftCount: Double = 0
        var rightCount: Double = 0
        if which == .Left {
            matchup.vote(Matchup.voteFor.A)
            print("matchup ID: \(matchup.ID), left is voted.")
            print("Before, A: \(matchup.countVoteA!), B: \(matchup.countVoteB!).")
            leftCount = Double(matchup.countVoteA!+1)
            rightCount = Double(matchup.countVoteB!)
        } else {
            matchup.vote(Matchup.voteFor.B)
            print("matchup ID: \(matchup.ID), right is voted.")
            print("Before, A: \(matchup.countVoteA!), B: \(matchup.countVoteB!).")
            leftCount = Double(matchup.countVoteA!)
            rightCount = Double(matchup.countVoteB!+1)
        }
        print("After, A: \(leftCount), B: \(rightCount).")
        
        let totalCount = leftCount + rightCount
        let leftPercentage: Double = leftCount / totalCount
        let rightPercentage: Double = rightCount / totalCount
        leftResultLabel.text = String(format: "%.0f", leftPercentage*100) + "%"
        rightResultLabel.text = String(format: "%.0f", rightPercentage*100) + "%"
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
        leftResultLabel.text = ""
        rightResultLabel.text = ""
        leftResultLabel.isHidden = true
        rightResultLabel.isHidden = true
        hashtagLabel.text = ""
    }
    
    func addAndConstrainSubviews() {
        
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
                               constant: AnimationViewConstraintConstants.barWidth),
            NSLayoutConstraint(item: leftBar,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.leftBarCalculatedHeight),
            NSLayoutConstraint(item: leftBar,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            ])
        
        contentView.addConstraints([
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
                               constant: AnimationViewConstraintConstants.barWidth),
            NSLayoutConstraint(item: rightBar,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.rightBarCalculatedHeight),
            NSLayoutConstraint(item: rightBar,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            ])
        
        //layout of other two elements off bar using autolayout
        
        
        leftLabel = UILabel()
        rightLabel = UILabel()
        
        guard let leftLabel = leftLabel, let rightLabel = rightLabel else {
            print("label is nil")
            return
        }
        
        leftLabel.text = leftLabelText
        rightLabel.text = rightLabelText
        
        leftImageView.addSubview(leftLabel)
        rightImageView.addSubview(rightLabel)
        
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            NSLayoutConstraint(item: leftLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: leftLabel,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftBar,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.barLabelSpacing),
            ])
        
        contentView.addConstraints([
            NSLayoutConstraint(item: rightLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightImageView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: rightLabel,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightBar,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.barLabelSpacing),
            ])
        
        contentView.addConstraints([
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: rightLabel,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkLabelSpacing),
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageWidth),
            NSLayoutConstraint(item: rightCheckMark,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageHeight),
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
        
        
        contentView.addConstraints([
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: leftLabel,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkLabelSpacing),
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageWidth),
            NSLayoutConstraint(item: leftCheckMark,
                               attribute: NSLayoutAttribute.height,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.height,
                               multiplier: 1.0,
                               constant: AnimationViewConstraintConstants.checkMarkImageHeight),
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
    }

    
    func createVotingAnimationSubviews() {
        //calculate percentages
        
//        guard let homeViewControllerDelegate = homeViewControllerDelegate else {
//            print("delegate is nil")
//            return
//        }
//        guard let matchup = homeViewControllerDelegate.matchup else {
//            print("matchup is nil")
//            return
//        }
//        guard let leftCount = matchup.countVoteA, let rightCount = matchup.countVoteB  else {
//            print("counts are nil")
//            return
//        }
//        
//        //convert int to double
//        //come up with cleaner way to do this in next iteration
//        
//        let leftCountConverted: Double = Double(leftCount)
//        let rightCountConverted: Double = Double(rightCount)
//        
//        //calculate total and percentages
//        let total = leftCountConverted + rightCountConverted
//        let leftPercentage: Double = (leftCountConverted / total)
//        let rightPercentage: Double = (rightCountConverted / total)
//        
//        //calculates totalheight of bar (contentviewheight - B(height of checkmark and label))
//        //note checkmarklabelspacing and barlabelspacing must inverted based on constraint setup
//        
//        let cellHeight = contentView.frame.size.height
//        let controlHeight = AnimationViewConstraintConstants.checkMarkImageHeight + AnimationViewConstraintConstants.winLabelHeight + -(AnimationViewConstraintConstants.checkMarkLabelSpacing)
//        let barHeight = cellHeight - controlHeight - -(AnimationViewConstraintConstants.barLabelSpacing)
//        
//        AnimationViewConstraintConstants.leftBarCalculatedHeight = barHeight * CGFloat(leftPercentage)
//        AnimationViewConstraintConstants.rightBarCalculatedHeight = barHeight * CGFloat(rightPercentage)
//        
//        //lays bar out with fixed height using autolyout
//        //layout of other two elements off bar using autolayout
//        
//        //hide elements to prepareforanimation
//        
//        addAndConstrainSubviews()
//        self.contentView.layoutIfNeeded()
//        resetAnimationState()
        
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
