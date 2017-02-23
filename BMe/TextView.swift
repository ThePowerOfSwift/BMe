//
//  TextView.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/22/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

private let defaultText = ":)"
private let defaultFont = UIFont(name: "Helvetica", size: 50)
private let defaultColor = UIColor.black

class TextView: UIView, UITextFieldDelegate {

    /** The view that holds and draws the line */
    private var imageView = UIImageView()
    
    // Text editing properties
    /** To store current font size for pinch gesture scaling */
    private var currentFontSize: CGFloat = 0
    /** the last rotation is the relative rotation value when rotation stopped last time,
     which indicates the current rotation */
    private var lastRotation: CGFloat = 0
    /** To store original center position for panned gesture */
    private var originalCenter: CGPoint?
    
    // Trackers
    private var currentTextField: UITextField?
    var currentColor: UIColor = defaultColor
    
    // CGContext
    /** Quality; 0.0 is screen resolution */
    private var imageScale: CGFloat = 0.00
    
    /** Returns all the text fields generated to be drawn */
    private var textFields: [UITextField] {
        get {
            var textFields: [UITextField] = []
            for view in imageView.subviews {
                if let textField = view as? UITextField {
                    textFields.append(textField)
                }
            }
            return textFields
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
    
    private func setup() {
        // Setup image view where draw actions are drawn
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedBackground(_:)))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
        
        // Observe keyboard appearance
        addKeyboardObserver()
        
    }
    
    // MARK: TextField editing
    
    /** Add a text field to the screen and begin editing */
    func addTextfield() {
        // Create new textfield
        let textField = UITextField()
        self.currentTextField = textField
        textField.delegate = self
        // Set textfield behaviour
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.spellCheckingType = .no
        textField.keyboardType = UIKeyboardType.asciiCapable
        textField.returnKeyType = .done
        textField.textColor = currentColor
        textField.font = defaultFont
        
        // Lay gestures into created text field
        // Change
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        // Double tap (to delete)
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedTextField(_:)))
        tap.numberOfTapsRequired = 2
        textField.addGestureRecognizer(tap)
        // Pan (to move)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pannedTextField(_:)))
        textField.addGestureRecognizer(pan)
        
        // Pinch (to scale)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchedTextField(_:)))
        textField.addGestureRecognizer(pinch)
        
        // Rotation (to rotate)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotatedTextField(_:)))
        textField.addGestureRecognizer(rotate)
        
        // Default appearance
        textField.attributedPlaceholder = NSAttributedString(string: defaultText, attributes: [NSForegroundColorAttributeName: currentColor])
        textField.sizeToFit()
        
        // Add textField to view
        textField.center = imageView.center
        textField.keyboardType = UIKeyboardType.default
        imageView.addSubview(textField)
        textField.becomeFirstResponder()
    }
    
    // MARK: Gesture responders
    
    /** On pinch, resize the textfield and it's contents */
    @objc private func pinchedTextField(_ sender: UIPinchGestureRecognizer) {
        if let textField = sender.view as? UITextField {
            if sender.state == .began {
                currentFontSize = textField.font!.pointSize
            } else if sender.state == .changed {
                textField.font = UIFont(name: textField.font!.fontName, size: currentFontSize * sender.scale)
                textFieldDidChange(textField)
            } else if sender.state == .ended {
                
            }
        }
    }
    
    /** Rotate the textfield and contents */
    @objc private func rotatedTextField(_ sender: UIRotationGestureRecognizer) {
        var originalRotation = CGFloat()
        if sender.state == .began {
            
            // the last rotation is the relative rotation value when rotation stopped last time,
            // which indicates the current rotation
            originalRotation = lastRotation
            
            // sender.rotation renews everytime the rotation starts
            // delta value but not absolute value
            sender.rotation = lastRotation
            
        } else if sender.state == .changed {
            
            let newRotation = sender.rotation + originalRotation
            sender.view?.transform = CGAffineTransform(rotationAngle: newRotation)
            
        } else if sender.state == .ended {
            
            // Save the last rotation
            lastRotation = sender.rotation
        }
    }
    
    /** On double tap remove the textfield */
    @objc private func doubleTappedTextField(_ sender: UITapGestureRecognizer) {
        let textField = sender.view
        textField?.removeFromSuperview()
    }
    
    /** On pan move the textfield */
    @objc private func pannedTextField(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            originalCenter = sender.view!.center
        } else if sender.state == UIGestureRecognizerState.changed {
            
            let translation = sender.translation(in: imageView)
            sender.view?.center = CGPoint(x: originalCenter!.x + translation.x , y: originalCenter!.y + translation.y)
            
        } else if sender.state == UIGestureRecognizerState.ended {
            
        }
    }
    
    /** Tapped on background: end editing on all textfields */
    @objc fileprivate func tappedBackground(_ sender: UITapGestureRecognizer) {
        imageView.endEditing(true)
    }
    
    private func removeTextfieldFromSubbiew() {
        for view in imageView.subviews {
            if let textField = view as? UITextField {
                textField.removeFromSuperview()
            }
        }
    }
    
    // MARK: Instance methods
    
    /** Render texts field into text image view. */
    func render() {
        
        // Configure context
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, imageScale)
//        imageView.image?.draw(in: imageView.frame)
        
        for textField in textFields {
            // Draw text in rect
//            let textLabelPointInImage = CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y)
//            let rect = CGRect(origin: textLabelPointInImage, size: imageView.frame.size)
//            textNSString.draw(in: rect, withAttributes: textFontAttributes)
            let rect = CGRect(origin: CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y), size: textField.frame.size)
            textField.drawText(in: rect)

        }
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    // MARK: UITextFieldDelegate
    
    /** Allow text fields to be edited */
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    /** On TextField change, resize the TextField */
    func textFieldDidChange(_ sender: UITextField) {
        sender.sizeToFit()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("Keyboard will show")
        /*
        let info  = notification.userInfo!
        guard let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            print("Error: Can't convert info[UIKeyboardFrameEndUserInfoKey] to CGRect")
            return
        }
        
        Constraint.BubbleCollectionView.Top.ShowWithKeyboard = UIScreen.main.bounds.height - keyboardFrame.height - bubbleCollectionView.frame.height
        isBubbleCollectionViewShown = false
        bubbleCollectionView.reloadData()
        toggleBubbleCollectionView()
        UIView.animate(withDuration: 0.1) {
            self.view.bringSubview(toFront: self.imageView)
            self.view.bringSubview(toFront: self.bubbleCollectionView)
            self.bubbleCollectionViewTopConstraint.constant = Constraint.BubbleCollectionView.Top.ShowWithKeyboard
            print("self.bubbleCollectionViewTopConstraint.constant: \(self.bubbleCollectionViewTopConstraint.constant)")
            self.view.layoutIfNeeded()
        }
        */
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("Keyboard will hide")
        /*
        if currentMode.isMode(mode: .Text) {
            UIView.animate(withDuration: 0.1) {
                self.view.bringSubview(toFront: self.imageView)
                self.view.bringSubview(toFront: self.bubbleCollectionView)
                self.bubbleCollectionViewTopConstraint.constant = Constraint.BubbleCollectionView.Top.Show
                self.view.layoutIfNeeded()
            }
        }
 */
    }

}
