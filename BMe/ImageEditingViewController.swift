//
//  CameraViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 11/30/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

protocol ImageEditingDelegate {
    func getChosenImage() -> UIImage?
}

class ImageEditingViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var cameraControlView: UIView!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
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
    var renderedImage: UIImage?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCamerView(_:)))
        cameraControlView.addGestureRecognizer(tap)
        
        // Get the picture user took
        //        chosenImage = delegate?.getChosenImage()
        //        imageView.image = chosenImage
        
        // Insert it above the editing view
        //view.insertSubview(imageView, at: 0)
        //hideCameraControlView()
        navigationController?.navigationBar.isHidden = true
        loadCamera()
        //showCameraControlView()
    }
    
    func hideCameraControlView() {
        cameraControlView.isHidden = true
    }
    
    func showCameraControlView() {
        cameraControlView.isHidden = false
    }
    
    // MARK: image picker
    func loadCamera() {
        presentCameraPicker(timeInterval: 0.5, delegate: self, completion: nil)
    }
    
    func presentCameraPicker(timeInterval: TimeInterval?, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), completion: (() -> Void)?) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = false
        // Set to camera & video record
        imagePicker.sourceType = .camera
        
        // Capable for video and camera
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        // Set maximum video length, if any
        if let timeInterval = timeInterval {
            imagePicker.videoMaximumDuration = timeInterval
        }
        
        present(imagePicker, animated: true) {
            if let completion = completion { completion() }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Delegate to return the chosen image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            
//            let scaleImageToScreenWidth = imageView.frame.width / image.size.width
//            let scaleImageToScreenHeight = imageView.frame.height / image.size.height
//            
//            let scaleScreenToImageWidth = image.size.width / imageView.frame.width
//            let scaleScreenToImageHeight = image.size.height / imageView.frame.height
//            
//            
//            let centerXInImage = image.size.width / 2
//            let centerYInImage = image.size.height / 2
//            
//            print("centerXInImage: \(centerXInImage)")
//            print("centerYInImage: \(centerYInImage)")
//            
//            // Add label to the center
//            let textLabelXInScreen = centerXInImage * scaleImageToScreenWidth
//            let textLabelYInScreen = centerYInImage * scaleImageToScreenHeight
//            print("textLabelXInScreen: \(textLabelXInScreen)")
//            print("textLabelYInScreen: \(textLabelYInScreen)")
//            
//            let textLabelPointInScreen = CGPoint(x: textLabelXInScreen, y: textLabelYInScreen)
//            print("textLabelPointInScreen: \(textLabelPointInScreen)")
//            let testLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
//            testLabel.backgroundColor = UIColor.black
//            testLabel.font = UIFont(name: "Helvetica", size: 10)
//            testLabel.textColor = UIColor.white
//            testLabel.text = "HELLO WORLD"
//            testLabel.center = textLabelPointInScreen
//            imageView.addSubview(testLabel)
//            
//            let textLabelXInImage = textLabelXInScreen * scaleScreenToImageWidth
//            let textLabelYInImage = textLabelYInScreen * scaleScreenToImageHeight
//            print("textLabelXInImage: \(textLabelXInImage)")
//            print("textLabelYInImage: \(textLabelYInImage)")
//            
//            let textLabelPointInImage = CGPoint(x: textLabelXInImage, y: textLabelYInImage)
//            
//            
//            let textNSString = NSString(string: testLabel.text!)
//            // Draw text in image
//            renderedImage = image.add(textNSString, to: textLabelPointInImage, color: nil, font: nil)
//            
//            
////            let storyboard = UIStoryboard(name: "Camera", bundle: nil)
////            let testVC = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
////            testVC.image = drawnImage
////            present(testVC, animated: true, completion: {
////                print("The drawn image is showing now")
////            
////            })
//            
//            
//            // pass
//            
//            print("imageView.image?.scale: \((imageView.image?.scale)!)")
//            print("UIScreen.main.scale: \(UIScreen.main.scale)")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Add Text To Image
    func add(_ image: UIImage, text: NSString, to point: CGPoint, color: UIColor?, font: UIFont?) -> UIImage {
        
        // Default colour white
        var textColor = UIColor.white
        if let color = color {
            textColor = color
        }
        // Default font
        var textFont = UIFont(name: "Helvetica Bold", size: 100)!
        if let font = font {
            textFont = font
        }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [NSFontAttributeName: textFont,
                                  NSForegroundColorAttributeName: textColor] as [String : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func add(textFields: [UITextField], to image: UIImage) -> UIImage? {
        
        let scaleScreenToImageWidth = image.size.width / imageView.frame.width
        let scaleScreenToImageHeight = image.size.height / imageView.frame.height
        
        // Configure context
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        for textField in textFields {
            // Prepare coordinate for text to set it in image
            let textLabelXInScreen = textField.frame.origin.x
            let textLabelYInScreen = textField.frame.origin.y
            print("textLabelXInScreen: \(textLabelXInScreen)")
            print("textLabelYInScreen: \(textLabelYInScreen)")
            
            let textLabelXInImage = textLabelXInScreen * scaleScreenToImageWidth
            let textLabelYInImage = textLabelYInScreen * scaleScreenToImageHeight
            print("textLabelXInImage: \(textLabelXInImage)")
            print("textLabelYInImage: \(textLabelYInImage)")
            let textLabelPointInImage = CGPoint(x: textLabelXInImage, y: textLabelYInImage)
            
            let textNSString = NSString(string: textField.text!)

            // Default colour white
            var textColor = UIColor.white
            if let color = textField.textColor {
                textColor = color
            }
            
            let textFont = UIFont(name: "Helvetica", size: 100)!
            let textFontAttributes = [NSFontAttributeName: textFont,
                                      NSForegroundColorAttributeName: textColor] as [String : Any]
            
            let rect = CGRect(origin: textLabelPointInImage, size: image.size)
            textNSString.draw(in: rect, withAttributes: textFontAttributes)
            
        }
    

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowRenderedImageSegue" {
//            let vc = segue.destination as! ShowImageViewController
//            vc.image = renderedImage
//        }
//    }
    
    @IBAction func onDone(_ sender: UIButton) {
        
        var editedImage: UIImage?
        
          let newImage = add(textFields: textFields, to: imageView.image!)
//        let scaleScreenToImageWidth = (imageView.image?.size.width)! / imageView.frame.width
//        let scaleScreenToImageHeight = (imageView.image?.size.height)! / imageView.frame.height
//        
//        // Configure context
//        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions((imageView.image?.size)!, false, scale)
//        
//        // Prepare coordinate for text to set it in image
//        let textLabelXInScreen = textFields[0].frame.origin.x
//        let textLabelYInScreen = textFields[0].frame.origin.y
//        print("textLabelXInScreen: \(textLabelXInScreen)")
//        print("textLabelYInScreen: \(textLabelYInScreen)")
//        
//        let textLabelXInImage = textLabelXInScreen * scaleScreenToImageWidth
//        let textLabelYInImage = textLabelYInScreen * scaleScreenToImageHeight
//        print("textLabelXInImage: \(textLabelXInImage)")
//        print("textLabelYInImage: \(textLabelYInImage)")
//        let textLabelPointInImage = CGPoint(x: textLabelXInImage, y: textLabelYInImage)
//        
//        let text = NSString(string: textFields[0].text!)
//        
//        let newImage = add(imageView.image!, text: text, to: textLabelPointInImage, color: nil, font: nil)
        
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        let testVC = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        testVC.image = newImage
        present(testVC, animated: true, completion: nil)
    }
    
    //MARK: - Manging Textfeld methods
    @IBAction func tappedAddTextButton(_ sender: Any) {
        addTextFieldToView()
    }
    
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




