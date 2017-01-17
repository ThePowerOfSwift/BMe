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

/**
 CameraViewDelegate protocol defines methods to show and hide things in delegate object. 
 In this case, the delegate object is TabBarViewController.
 */
protocol TabBarViewControllerDelegate {
    func hideScrollTitle()
    func showScrollTitle()
    func hideTabBar()
    func showTabBar()
}

class CameraViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var cameraControlView: UIView!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationButton: LocationButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Delegate
    var tabBarViewControllerDelegate: TabBarViewControllerDelegate?
    
    //MARK:- Model
    fileprivate var textFields: [UITextField] {
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
    fileprivate var chosenImage: UIImage?
    fileprivate var renderedImage: UIImage?
    fileprivate var metadata: [String: AnyObject?]?
    
    fileprivate var imagePicker: UIImagePickerController?
    fileprivate var imagePickerView: UIView?
    
    // Detect current mode
    fileprivate var isCameraMode: Bool?
    fileprivate var isEditingMode: Bool?
    
    // Title
    fileprivate var titleLabel: UILabel?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedBackground(_:)))
        cameraControlView.addGestureRecognizer(tap)
        
        //TODO: - haha
        metadata = ["missing metadata" : "you didn't add metadata for this pic, bitch!" as Optional<AnyObject>]
        
        setupButtons()
        //addImagePickerToSubview(timeInterval: 0.5, delegate: self, completion: nil)
        setupCaptureSession()
        
        enterCameraMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // cameraView resizes incorrectly for some reason.
        // At first call, cameraView.bounds is (0.0, 0.0, 375.0, 667.0)
        // At second call, cameraView.bounds is (0.0, 0.0, 414.0, 736.0)
        // Use UIScreen.main.bounds instead
        //previewLayer?.frame = cameraView.bounds
        previewLayer?.frame = UIScreen.main.bounds
        print("cameraView.bounds: \(cameraView.bounds)")
    }
    

    internal func takePicture() {
        if isCameraMode! {
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
    }
    
    private func setupButtons() {
        // Button Configuration
        addButton.tintColor = Styles.Color.Tertiary
        
        uploadButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 40)
        uploadButton.tintColor = Styles.Color.Tertiary
        uploadButton.setTitle(String.fontAwesomeIcon(name: .upload), for: .normal)
        
        locationButton.delegate = self
        
        cancelButton.tintColor = Styles.Color.Tertiary
    }
    
    // MARK: Mode switching
    private func enterCameraMode() {
        cameraView.isHidden = false
        cameraControlView.isHidden = true
        isEditingMode = false
        isCameraMode = true
        tabBarViewControllerDelegate?.showScrollTitle()
        tabBarViewControllerDelegate?.showTabBar()
    }
    
    fileprivate func enterEditMode() {
        cameraView.isHidden = true
        cameraControlView.isHidden = false
        isCameraMode = false
        isEditingMode = false
        tabBarViewControllerDelegate?.hideScrollTitle()
        tabBarViewControllerDelegate?.hideTabBar()
    }
    
    @IBAction func onUpload(_ sender: UIButton) {
        
        let busy = BusyView()
        busy.view.center = self.view.center
        self.view.addSubview(busy)
        busy.startAnimating()
        
        var newImage = editImageView.image
        if textFields.count > 0 {
            newImage = add(textFields: textFields, to: editImageView.image!)
        }
        
        // Resize the image
        var localID: String!
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: newImage!)
            localID = (creationRequest.placeholderForCreatedAsset?.localIdentifier)!
        }, completionHandler: { (success, error) in
            let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localID], options: nil)
            let imageSize = newImage?.size
            
            // Why is scaling needed?
            //let scale: CGFloat = Constants.ImageCompressionAndResizingRate.resizingScale
            //let targetSize = CGSize(width: imageSize!.width * scale, height: imageSize!.height * scale)
            let targetSize = imageSize!
            
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            PHImageManager.default().requestImage(for: phAssets.firstObject!, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                // use image
                // Convert image to JPEG with specified compression quality
                let imageData = UIImageJPEGRepresentation(image!, Constants.ImageCompressionAndResizingRate.compressionRate)
                FIRManager.shared.postObject(object: imageData!, contentType: .image, meta: self.metadata!, completion: {
                    print("Upload completed")
                    self.removeAllItems()
                    busy.stopAnimating()
                    busy.removeFromSuperview()
                    self.enterCameraMode()
                })
            })
        })
    }
    
    private func removeAllItems() {
        removeTextfieldFromSubbiew()
        metadata?.removeAll()
        locationButton.changeImageDefault()
        editImageView.image = nil
    }
    
    // MARK: Button Actionss
    @IBAction func onCancel(_ sender: UIButton) {
        removeAllItems()
        enterCameraMode()
        if didTakePhoto {
            didTakePhoto = false
        }
    }
    
    //MARK: - Manging Textfeld methods
    @IBAction func tappedAddTextButton(_ sender: Any) {
        addNewTextFieldToCameraControlView()
    }
    
    // To store current font size for pinch gesture scaling
    fileprivate var currentFontSize: CGFloat?
    fileprivate var lastRotation: CGFloat = 0

    // To store original center position for panned gesture
    fileprivate var originalCenter: CGPoint?
    
    // MARK: Properties for AVCapturePhotoOutput
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var didTakePhoto = Bool()
    @IBOutlet weak var cameraView: UIImageView!

}

// MARK: Text Field
extension CameraViewController: UITextFieldDelegate {
    
    // MARK: Add Text To Image
    fileprivate func add(textFields: [UITextField], to image: UIImage) -> UIImage? {
        
        let scaleScreenToImageWidth = image.size.width / editImageView.frame.width
        let scaleScreenToImageHeight = image.size.height / editImageView.frame.height
        
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
            let fontSize = textField.font?.pointSize
            let textFont = UIFont(name: "Helvetica", size: fontSize! * scaleScreenToImageWidth)!
            let textFontAttributes = [NSFontAttributeName: textFont,
                                      NSForegroundColorAttributeName: textColor] as [String : Any]
            
            // Draw text in rect
            let rect = CGRect(origin: textLabelPointInImage, size: image.size)
            
            textNSString.draw(in: rect, withAttributes: textFontAttributes)
            
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // To test
//        let testVC = UIViewController()
//        let testImageView = UIImageView(image: newImage)
//        testImageView.frame = UIScreen.main.bounds
//        testImageView.contentMode = UIViewContentMode.scaleAspectFit
//        testVC.view.addSubview(testImageView)
//        present(testVC, animated: true, completion: nil)
        
        return newImage
    }
    
    // Add the next text field to the screen
    fileprivate func addNewTextFieldToCameraControlView() {
        // Create new textfield
        let textField = UITextField()
        textField.delegate = self

        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.spellCheckingType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .done
        textField.textColor = UIColor.white
        textField.font = UIFont(name: "Helvetica", size: 50)
        
        // Add didedit event notifier
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        // Add double tap (to delete)
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedTextField(_:)))
        tap.numberOfTapsRequired = 2
        textField.addGestureRecognizer(tap)
        // Add pan (to move)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pannedTextField(_:)))
        textField.addGestureRecognizer(pan)
        
        // Add pinch gesture (to scale)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchedTextField(_:)))
        textField.addGestureRecognizer(pinch)
        
        // Add rotation gesture (to rotate)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotatedTextField(_:)))
        textField.addGestureRecognizer(rotate)
        
        // Default appearance
        textField.attributedPlaceholder = NSAttributedString(string: "T", attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.sizeToFit()
        
        // Add textField to cameraControlView
        textField.center = cameraControlView.center
        textField.keyboardType = UIKeyboardType.default
        cameraControlView.addSubview(textField)
        textField.becomeFirstResponder()
    }
    
    // MARK: Pinch Text Field
    // http://stackoverflow.com/questions/13669457/ios-scaling-uitextview-with-pinching
    // http://stackoverflow.com/questions/13439797/change-font-size-uitextfield-when-pinch
    @objc private func pinchedTextField(_ sender: UIPinchGestureRecognizer) {
        if let textField = sender.view as? UITextField {
            if sender.state == .began {
                currentFontSize = textField.font?.pointSize
            } else if sender.state == .changed {
                textField.font = UIFont(name: textField.font!.fontName, size: currentFontSize! * sender.scale)
                textFieldDidChange(textField)
            } else if sender.state == .ended {
                
            }
        }
    }
    
    // http://www.avocarrot.com/blog/implement-gesture-recognizers-swift/
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
    
    // MARK: Removing
    fileprivate func removeTextfieldFromSubbiew() {
        for view in cameraControlView.subviews {
            if let textField = view as? UITextField {
                textField.removeFromSuperview()
            }
        }
    }
    
    // On change resize the view
    @objc private func textFieldDidChange(_ sender: UITextField) {
        sender.sizeToFit()
    }
    
    // On double tap remove the textfield
    @objc private func doubleTappedTextField(_ sender: UITapGestureRecognizer) {
        let textField = sender.view
        textField?.removeFromSuperview()
    }
    
    // On pan move the textfield
    @objc private func pannedTextField(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            originalCenter = sender.view!.center
        } else if sender.state == UIGestureRecognizerState.changed {

            let translation = sender.translation(in: cameraControlView)
            sender.view?.center = CGPoint(x: originalCenter!.x + translation.x , y: originalCenter!.y + translation.y)

        } else if sender.state == UIGestureRecognizerState.ended {
            
        }
            
    }
    
    // Tapped on background: end editing on all textfields
    @objc fileprivate func tappedBackground(_ sender: UITapGestureRecognizer) {
        cameraControlView.endEditing(true)
    }
    
    internal func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: image picker
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    fileprivate func addImagePickerToSubview(timeInterval: TimeInterval?, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), completion: (() -> Void)?) {
//        imagePicker = UIImagePickerController()
//        imagePicker?.delegate = delegate
//        imagePicker?.allowsEditing = false
//        // Set to camera & video record
//        imagePicker?.sourceType = .camera
//        
//        // Capable for video and camera
//        imagePicker?.mediaTypes = [kUTTypeImage as String]
//        
//        // Set maximum video length, if any
//        if let timeInterval = timeInterval {
//            imagePicker?.videoMaximumDuration = timeInterval
//        }
//        
//        imagePicker?.showsCameraControls = false
//        
//        // http://stackoverflow.com/questions/2674375/uiimagepickercontroller-doesnt-fill-screen
////        let screenSize = UIScreen.main.bounds.size
////        let cameraAspectRatio: CGFloat = 4.0 / 3.0
////        let imageWidth = floor(screenSize.width * cameraAspectRatio)
////        let scale = ceil((screenSize.height) / imageWidth)
////        imagePicker?.cameraViewTransform = CGAffineTransform(scaleX: scale, y: scale)
//        imagePickerView = imagePicker?.view
//        imagePicker?.view.frame.origin.y = 75
//        view.addSubview((imagePicker?.view)!)
//    }
//    
//    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        // Delegate to return the chosen image
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            editImageView.image = image
//            enterEditMode()
//        }
//    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    internal func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var input: AVCaptureInput?
        
        do {
            try input = AVCaptureDeviceInput(device: backCamera)
        } catch {
            print("error")
        }
        
        if input != nil && captureSession!.canAddInput(input) {
            captureSession?.addInput(input)
            
            photoOutput = AVCapturePhotoOutput()
            
            if captureSession!.canAddOutput(photoOutput) {
                captureSession?.addOutput(photoOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)
                
                captureSession?.startRunning()
                
            }
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        let dataProvider = CGDataProvider(data: imageData as! CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
        self.editImageView.image = image
        enterEditMode()
    }
    
    func didPressTakePhoto() {
        if let videoConnection = photoOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])
            photoOutput?.capturePhoto(with: settings, delegate: self)
            
        }
    }
}

extension CameraViewController: LocationButtonDelegate {
    internal func locationButton(yelpDidSelect restaurant: Restaurant) {
        metadata = restaurant.dictionary
    }
    
    internal func locationButton(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> ())?) {
        present(viewControllerToPresent, animated: true, completion: {
        })
    }
}
