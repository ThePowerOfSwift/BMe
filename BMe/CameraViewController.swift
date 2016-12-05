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
import FontAwesome_swift

class CameraViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationButtonDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var cameraControlView: UIView!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationButton: LocationButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
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
    var renderedImage: UIImage?
    var metadata: [String: AnyObject?]?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCamerView(_:)))
        cameraControlView.addGestureRecognizer(tap)
        
        navigationController?.navigationBar.isHidden = true
        
        metadata = ["missing metadata" : "you didn't add metadata for this pic, bitch!" as Optional<AnyObject>]
        
        hideCameraControlView()
        setupButtons()
        loadCamera()
        
    }
    
    func setupButtons() {
        // Button Configuration
        addButton.tintColor = Styles.Color.Tertiary
        
        uploadButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 40)
        uploadButton.tintColor = Styles.Color.Tertiary
        uploadButton.setTitle(String.fontAwesomeIcon(name: .upload), for: .normal)
        
        locationButton.delegate = self
        
        cancelButton.tintColor = Styles.Color.Tertiary
        
    }
    
    func locationButton(yelpDidSelect restaurant: Restaurant) {
        metadata = restaurant.dictionary
    }
    
    func locationButton(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> ())?) {
        present(viewControllerToPresent, animated: true, completion: {
        })
    }
    // MARK: Camera
    
    func hideCameraControlView() {
        cameraControlView.isHidden = true
    }
    
    func showCameraControlView() {
        cameraControlView.isHidden = false
    }
    
    // MARK: image picker
    func loadCamera() {
        presentCameraPicker(timeInterval: 0, delegate: self, completion: nil)
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
        
        imagePicker.showsCameraControls = false
        
        let screenSize = UIScreen.main.bounds.size
        let cameraAspectRatio: CGFloat = 4.0 / 3.0
        let imageWidth = floor(screenSize.width * cameraAspectRatio)
        let scale = ceil((screenSize.height) / imageWidth )

        imagePicker.cameraViewTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        present(imagePicker, animated: false) {
            imagePicker.takePicture()
            if let completion = completion { completion() }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Delegate to return the chosen image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            picker.dismiss(animated: true, completion: {
                self.showCameraControlView()
            })
        }
    }
    
    // MARK: Add Text To Image
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
            
            // Find where to put text in image
            let textLabelXInImage = textLabelXInScreen * scaleScreenToImageWidth
            let textLabelYInImage = textLabelYInScreen * scaleScreenToImageHeight
            let textLabelPointInImage = CGPoint(x: textLabelXInImage, y: textLabelYInImage)
            
            // Text Attributes
            let textNSString = NSString(string: textField.text!)
            let textColor = UIColor.white
            let textFont = UIFont(name: "Helvetica", size: 150)!
            let textFontAttributes = [NSFontAttributeName: textFont,
                                      NSForegroundColorAttributeName: textColor] as [String : Any]
            
            // Draw text in rect
            let rect = CGRect(origin: textLabelPointInImage, size: image.size)
            textNSString.draw(in: rect, withAttributes: textFontAttributes)
            
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func onUpload(_ sender: UIButton) {
        let newImage = add(textFields: textFields, to: imageView.image!)
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        let testVC = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        testVC.image = newImage
        
        let imageData = UIImageJPEGRepresentation(newImage!, 1)


        FIRManager.shared.postObject(object: imageData!, contentType: .image, meta: metadata!, completion: {
            print("Upload completed")
        })
        
        //self.present(testVC, animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        hideCameraControlView()
        loadCamera()
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
        textField.autocapitalizationType = .allCharacters
        textField.spellCheckingType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .done
        textField.textColor = UIColor.white
        textField.font = UIFont(name: "Helvetica", size: 20)
        
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
        textField.attributedPlaceholder = NSAttributedString(string: "TYPE TEXT HERE", attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.sizeToFit()
        
        // Add textField to cameraControlView
        textField.center = cameraControlView.center
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
            textField.center = point
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
