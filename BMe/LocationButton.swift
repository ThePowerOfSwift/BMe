//
//  LocationButton.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/4/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

@objc protocol LocationButtonDelegate: class {
    @objc optional func locationButton(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (()->())?)
    @objc optional func locationButton(yelpDidSelect restaurant: Restaurant)
}
class LocationButton: UIButton, YelpViewControllerDelegate {

    let yelpVC = UIStoryboard(name: Constants.SegueID.Storyboard.Yelp, bundle: nil).instantiateInitialViewController() as! YelpViewController
    weak var delegate: LocationButtonDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        changeImageDefault()
        yelpVC.delegate = self
        addTarget(self, action: #selector(tappedButton(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func tappedButton(_ sender: UIButton) {
        delegate?.locationButton?(yelpVC, animated: true, completion: nil)
    }

    func changeImageDefault() {
        let defaultImage = UIImage(named: Constants.Images.location)
        setImage(defaultImage, for: UIControlState.normal)
        
    }
    
    func changeImageHighlighted() {
        let highlightedImage = UIImage(named: Constants.Images.locationYellow)
        setImage(highlightedImage, for: UIControlState.normal)
    }
    
// MARK: - Yelp picker delegate methods

    func yelp(didSelect restaurant: Restaurant) {
        delegate?.locationButton?(yelpDidSelect: restaurant)
        changeImageHighlighted()
    }
}
