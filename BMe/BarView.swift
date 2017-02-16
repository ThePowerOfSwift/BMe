//
//  BarView.swift
//  BMe
//
//  Created by parry on 2/13/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//
//  BarView creates an animating bar on a particular parentview.  The bar animates by starting with a transform of 1/4 of the size to full size using a UIView spring animation.
//  BarView also adds a resultLabel on top of the bar.  This shows the percentage and can be triggered by calling showBar
//  BarView is reset after the completion of the animation avoid constraint issues

import UIKit

struct BarConstraintConstants {
    static var barLabelSpacing: CGFloat = -25
    static var barCalculatedHeight: CGFloat = 0
    static var rightBarCalculatedHeight: CGFloat = 0
    static let winLabelHeight: CGFloat = 20.5
    static let barWidth: CGFloat = 6
}

class BarView: UIView {
    //the view that the bar will animate in
    var parentView: UIView? {
        didSet {
            addToParent()
            addLabelToParent()
        }
    }
    var percentage: Double?
    var resultLabel = UILabel()
    var heightConstraint:NSLayoutConstraint?
    
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
     Creates new Bar instance
     
     This method takes in the parent view and sets the parent view.  The method then calls addtoParent and addLabelToParent methods which constrain the bar to the parent and add and constrains the result label respectively
     
     :param: parentView the view that the bar will animate in
     
     :returns:   new BarView instance
     */
    convenience init(parentView: UIView) {
        self.init(frame: CGRect.zero)
        self.parentView = parentView
        addToParent()
        addLabelToParent()
    }
    
    
    //sets bar with an initial transform and color
    func setup() {
        self.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        self.backgroundColor = UIColor.red
    }
    
    private func addToParent()
    {
        //adds to parent and centers in parentview
        guard let parentView = parentView else {
            print("parentview is nil")
            return
        }
        
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //give bar initial height of 0
        heightConstraint = NSLayoutConstraint(item: self,
                                              attribute: NSLayoutAttribute.height,
                                              relatedBy: NSLayoutRelation.equal,
                                              toItem: nil,
                                              attribute: NSLayoutAttribute.height,
                                              multiplier: 1.0,
                                              constant: 0)
        
        guard let heightConstraint = heightConstraint else {
            print("heightConstraint is nil")
            return
        }
        
        parentView.addConstraints([
            NSLayoutConstraint(item: self,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: parentView,
                               attribute: NSLayoutAttribute.bottom,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: self,
                               attribute: NSLayoutAttribute.width,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: nil,
                               attribute: NSLayoutAttribute.width,
                               multiplier: 1.0,
                               constant: BarConstraintConstants.barWidth),
            heightConstraint,
            NSLayoutConstraint(item: self,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: parentView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            ])
    }
    
    /**
     Animates bar to a particular height constant
     
     This method takes in a percentage value as an Int. This value is a converted to a decimal and then multiplied by the full bar height
     
     :param: percent the percent that the full bar height should change to
     
     */
    func animateBar(_ percent: Int)
    {
        self.isHidden = false
        
        percentage = Double(percent)
        if let per = percentage {
            percentage = per / 100
        }
        
        calculateBarHeight()
        
        //set new height based on calculated height.  In autolayout world constraint must be deactivated then added and reactivated
        
        if var heightConstraint = heightConstraint {
            heightConstraint.isActive = false
            heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: NSLayoutAttribute.height,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutAttribute.height,
                                                  multiplier: 1.0,
                                                  constant: BarConstraintConstants.barCalculatedHeight)
            heightConstraint.isActive = true
        }else {
            heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: NSLayoutAttribute.height,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutAttribute.height,
                                                  multiplier: 1.0,
                                                  constant: BarConstraintConstants.barCalculatedHeight)

        }
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [] , animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { (success) in
            self.reset()
        })
    }
    
    //resets bar to prepare for another animation
    func reset() {
        self.isHidden = true
        self.resultLabel.isHidden = true
        self.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        heightConstraint = nil
    }
    
    func addLabelToParent() {
        //adds resultLabel above BarView
        guard let parentView = parentView else {
            print("parentview is nil")
            return
        }
        parentView.addSubview(resultLabel)
        
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addConstraints([
            NSLayoutConstraint(item: resultLabel,
                               attribute: NSLayoutAttribute.centerX,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: parentView,
                               attribute: NSLayoutAttribute.centerX,
                               multiplier: 1.0,
                               constant: 0),
            NSLayoutConstraint(item: resultLabel,
                               attribute: NSLayoutAttribute.bottom,
                               relatedBy: NSLayoutRelation.equal,
                               toItem: self,
                               attribute: NSLayoutAttribute.top,
                               multiplier: 1.0,
                               constant: BarConstraintConstants.barLabelSpacing),
            ])
        
        resultLabel.backgroundColor = UIColor.white
        resultLabel.textAlignment = .center
        resultLabel.isHidden = true
    }
    
    func showValue() {
        //shows resultLabels value
        guard let percentage = percentage else {
            print("parentview is nil")
            return
        }
        resultLabel.isHidden = false
        resultLabel.text = String(format: "%.0f", percentage*100) + "%"
    }
    
    
    private func calculateBarHeight() {
        guard let parentView = parentView, let percentage = percentage else {
            print("parentview is nil")
            return
        }
        
        //calculates totalheight of bar (parentViewHeight - B(height of label and spacing))
        let cellHeight = parentView.frame.size.height
        let controlHeight = BarConstraintConstants.winLabelHeight
        let barHeight = cellHeight - controlHeight - -(BarConstraintConstants.barLabelSpacing)
        
        BarConstraintConstants.barCalculatedHeight = barHeight * CGFloat(percentage)
    }
}
