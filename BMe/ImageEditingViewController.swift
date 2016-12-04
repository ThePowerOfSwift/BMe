//
//  CameraViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/30/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit

protocol ImageEditingDelegate {
    func getChosenImage() -> UIImage?
}

class ImageEditingViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var cameraControlView: UIView!
    @IBOutlet weak var addTextButton: UIButton!

    @IBAction func tappedAddTextButton(_ sender: Any) {
        addTextFieldToView()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func onDone(_ sender: UIButton) {
        
        var editedImage: UIImage?

        //editedImage = chosenImage?.add(textFields: textFields, view: self.view)
        editedImage = chosenImage?.add(textFields: textFields)
        
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        let testVC = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        testVC.image = editedImage
        present(testVC, animated: true, completion: nil)
    }
    
    //MARK:- Model
    var textFields: [UITextField] {
        get {
            var textFields: [UITextField] = []
            for view in cameraControlView.subviews {
                //grab textfields
                if let textField = view as? UITextField {
                    textFields.append(textField)
                }
            }
            return textFields
        }
    }
    
    //MARK:- Variables
    var chosenImage: UIImage?
    var delegate: ImageEditingDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCamerView(_:)))
        cameraControlView.addGestureRecognizer(tap)
        
        // Get the picture user took
        chosenImage = delegate?.getChosenImage()
        imageView.image = chosenImage
        
        // Insert it above the editing view
        view.insertSubview(imageView, at: 0)
    }

    //MARK: - Manging Textfeld methods
   
    // Add a next text field to the screen
    func addTextFieldToView() {
        // Create new textfield
        let textField = UITextField()
        textField.delegate = self

        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.spellCheckingType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .done
        
        // Add didedit event notifier
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        // Add double tap (to delete)
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedTextField(_:)))
        tap.numberOfTapsRequired = 2
        textField.addGestureRecognizer(tap)
        // Add pan (to move)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pannedTextField(_:)))
        textField.addGestureRecognizer(pan)
        
        // Default appearance
        textField.placeholder = "T"
        textField.sizeToFit()
        
        textField.frame.origin = cameraControlView.center
        
        cameraControlView.addSubview(textField)
        textField.becomeFirstResponder()
    }
    
    // On change resize the view
    func textFieldDidChange(_ sender: UITextField) {
        sender.sizeToFit()
    }
    
    // On double tap remove the textfield
    func doubleTappedTextField(_ sender: UITapGestureRecognizer) {
        let textField = sender.view
        textField?.removeFromSuperview()
    }
    
    // On pan move the textfield
    func pannedTextField(_ sender: UIPanGestureRecognizer) {
        if let textField = sender.view {
        
            let point = sender.location(in: cameraControlView)
            textField.frame.origin = point
        }
    }
    
    //MARK: - Textfield Delegate & FirstResponder methods
    // Tapped on background: end editing on all textfields
    func tappedCamerView(_ sender: UITapGestureRecognizer) {
        cameraControlView.endEditing(true)
    }
    

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension UIImage {
    
    func add(textFields: [UITextField]) -> UIImage {
        let screenSize = UIScreen.main.bounds
        
        let screenSizeCG = CGSize(width: screenSize.width, height: screenSize.height)
        
        let manualScale = UIScreen.main.bounds.width / self.size.width
        let scale = UIScreen.main.scale
        print("manualScale: \(manualScale)")
        print("scale: \(scale)")
        print("image: \(self.size)")
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        //UIGraphicsBeginImageContext(screenSizeCG)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))

        // Draw text in each textField
        for textField in textFields {
            
            let text = NSString(string: textField.text!)
            let point = CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y)
            
            let color = textField.textColor
            let font = textField.font
            
            // Default colour white
            var textColor = UIColor.white
            if let color = color {
                textColor = color
            }
            
            let textScale = self.size.width / UIScreen.main.bounds.width

            // Default font
            var textFont = UIFont(name: "Helvetica Bold", size: 200)!
            if let font = font {
                textFont = UIFont(name: "Helvetica Bold", size: font.pointSize * textScale)!
            }
            
            print("point: \(point)")
            
            let textFontAttributes = [NSFontAttributeName: textFont,
                                      NSForegroundColorAttributeName: textColor] as [String : Any]
            
            let textRectSize = CGSize(width: screenSize.width, height: screenSize.width)
            let textPoint = CGPoint(x: point.x * textScale, y: point.y * textScale)
            let textRect = CGRect(origin: textPoint, size: textRectSize)
            text.draw(in: textRect, withAttributes: textFontAttributes)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
//    func add(textFields: [UITextField], view: UIView) -> UIImage {
//        let screenSizeCG = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        
//        // Get screen size
//        let screenWidth: CGFloat = view.frame.size.width
//        let screenHeight: CGFloat = view.frame.size.height
//        
//        // Generate the range to draw
//        let imageRect = CGRect(x:0, y:0, width: self.size.width, height: self.size.height)
//        UIGraphicsBeginImageContext(self.size)
//        
//        // Render this image
//        self.draw(in: imageRect)
//        
//        UIGraphicsBeginImageContextWithOptions(screenSizeCG, false, scale)
//        //UIGraphicsBeginImageContext(screenSizeCG)
//        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
//        
//        // Draw text in each textField
//        for textField in textFields {
//            
//            let text = NSString(string: textField.text!)
//            let point = CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y)
//            let color = textField.textColor
//            let font = textField.font
//            
//            // Default colour white
//            var textColor = UIColor.white
//            if let color = color {
//                textColor = color
//            }
//            // Default font
//            var textFont = UIFont(name: "Helvetica Bold", size: 200)!
//            if let font = font {
//                //textFont = font
//            }
//            
//            let textFontAttributes = [NSFontAttributeName: textFont,
//                                      NSForegroundColorAttributeName: textColor] as [String : Any]
//            
//            // Generate the range to draw text
//            let textRectSize: CGSize = CGSize(width: 50, height: 20)
//            let textRect = CGRect(origin: point, size: textRectSize)
//            text.draw(in: textRect, withAttributes: textFontAttributes)
//        }
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
}

