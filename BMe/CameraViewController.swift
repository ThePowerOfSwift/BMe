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
import Photos

@objc protocol CameraViewDelegate {
    @objc optional func hideScrollTitle()
    @objc optional func showScrollTitle()
    @objc optional func hideTabBar()
    @objc optional func showTabBar()
}

class CameraViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationButtonDelegate, CameraViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var cameraControlView: UIView!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationButton: LocationButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Delegate
    var cameraViewDelegate: CameraViewDelegate?
    
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
        
        set {
            // Empty set is needed to remove all items
        }
    }
    
    //MARK:- Variables
    var chosenImage: UIImage?
    var renderedImage: UIImage?
    var metadata: [String: AnyObject?]?
    
    var imagePicker: UIImagePickerController?
    var imagePickerView: UIView?
    //var cameraButton: UIButton?
    
    // Detect current mode
    var isCameraMode: Bool?
    var isEditingMode: Bool?
    
    // Title
    var titleLabel: UILabel?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCamerView(_:)))
        cameraControlView.addGestureRecognizer(tap)
        
        //TODO: - haha
        metadata = ["missing metadata" : "you didn't add metadata for this pic, bitch!" as Optional<AnyObject>]
        
        //hideCameraControlView()
        setupButtons()
        addImagePickerToSubview(timeInterval: 0.5, delegate: self, completion: nil)
        enterCameraMode()
    }
    
    func takePicture() {
        if isCameraMode! {
            imagePicker?.takePicture()
        }
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
    
    // MARK: Mode switching
    func enterCameraMode() {
        cameraControlView.isHidden = true
        imagePickerView?.isHidden = false
        isEditingMode = false
        isCameraMode = true
        cameraViewDelegate?.showScrollTitle!()
        cameraViewDelegate?.showTabBar!()
    }
    
    func enterEditMode() {
        imagePickerView?.isHidden = true
        cameraControlView.isHidden = false
        isCameraMode = false
        isEditingMode = false
        cameraViewDelegate?.hideScrollTitle!()
        cameraViewDelegate?.hideTabBar!()
    }
    
    // MARK: image picker
    
    func addImagePickerToSubview(timeInterval: TimeInterval?, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), completion: (() -> Void)?) {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = delegate
        imagePicker?.allowsEditing = false
        // Set to camera & video record
        imagePicker?.sourceType = .camera
        
        // Capable for video and camera
        imagePicker?.mediaTypes = [kUTTypeImage as String]
        
        // Set maximum video length, if any
        if let timeInterval = timeInterval {
            imagePicker?.videoMaximumDuration = timeInterval
        }
        
        imagePicker?.showsCameraControls = false
        
        // http://stackoverflow.com/questions/2674375/uiimagepickercontroller-doesnt-fill-screen
        let screenSize = UIScreen.main.bounds.size
        let cameraAspectRatio: CGFloat = 4.0 / 3.0
        let imageWidth = floor(screenSize.width * cameraAspectRatio)
        //let scale = ceil(((screenSize.height) / imageWidth) * 10.0) / 10.0
        let scale = ceil((screenSize.height) / imageWidth)
        imagePicker?.cameraViewTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        imagePickerView = imagePicker?.view
        view.addSubview((imagePicker?.view)!)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Delegate to return the chosen image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            enterEditMode()
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
        print("update button tapped.")
        var newImage = imageView.image
        if textFields.count > 0 {
            newImage = add(textFields: textFields, to: imageView.image!)
        }
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        let testVC = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        testVC.image = newImage
        
        
        // Resize the image
        var localID: String!
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: newImage!)
            localID = (creationRequest.placeholderForCreatedAsset?.localIdentifier)!
        }, completionHandler: { (success, error) in
            let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localID], options: nil)
            let imageSize = newImage?.size
            let scale: CGFloat = Constants.ImageCompressionAndResizingRate.resizingScale
            let targetSize = CGSize(width: imageSize!.width * scale, height: imageSize!.height * scale)
            
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            PHImageManager.default().requestImage(for: phAssets.firstObject!, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                // use image
                // Convert image to JPEG with specified compression quality
                let imageData = UIImageJPEGRepresentation(image!, Constants.ImageCompressionAndResizingRate.compressionRate)
                print("image size: \(imageData!.count)")
                FIRManager.shared.postObject(object: imageData!, contentType: .image, meta: self.metadata!, completion: {
                    print("Upload completed")
                    self.removeAllItems()
                    self.enterCameraMode()
                })
            })
        })
    }
    
    // MARK: Removing
    func removeTextfieldFromSubbiew() {
        for view in cameraControlView.subviews {
            if let textField = view as? UITextField {
                textField.removeFromSuperview()
            }
        }
    }
    
    func removeAllItems() {
        removeTextfieldFromSubbiew()
        metadata?.removeAll()
        locationButton.changeImageDefault()
        imageView.image = nil
    }
    
    // MARK: Button Actionss
    @IBAction func onCancel(_ sender: UIButton) {
        removeAllItems()
        enterCameraMode()
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
        textField.attributedPlaceholder = NSAttributedString(string: "T", attributes: [NSForegroundColorAttributeName: UIColor.white])
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
