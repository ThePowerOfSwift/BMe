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
import ColorSlider

// MARK: - Protocols
/**
 CameraViewDelegate protocol defines methods to show and hide things in delegate object.
 In this case, the delegate object is TabBarViewController.
 
 The reason why this class needs to have tab bar view controller as a delegate is 
 to control tab bar behaviour. For example, your need to hide tab bar when you're in
 photo edit mode. You can get the reference to tab bar view controller from here by
 going up parent view controller, but there is page view controller between them and 
 going through page view controller need more work to get the reference to tab bar view controller.
 Using delegate is simpler way.
 */
protocol CameraViewControllerDelegate {
    
    // These four methods should be implemented in tab bar view controller
    /** Shows scroll title label when camera mode is on. Called by camera view controller. */
    func showTitleScrollView()
    /** Hide scroll title label when photo edit mode is on. Called by camera view controller. */
    func hideTitleScrollView()
    /** Show tab bar when camera mode is on. Called by camera view controller. */
    func showTabBar()
    /** Hide tab bar when photo edit mode is on. Called by camera view controller. */
    func hideTabBar()
    
}

class CameraViewController: UIViewController {
    
    //MARK: - Outlets
    // Views
    @IBOutlet weak var photoEditView: UIView!   // view which all the buttons are the subview of
    @IBOutlet weak var mainImageView: UIImageView!  // image view taken by the camera. text and drawings is rendered into this image view
    @IBOutlet weak var cameraView: UIImageView!     // view where camera exists
    
    // Buttons
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationButton: LocationButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // To change the color of text and drawing
    @IBOutlet weak var colorSliderView: UIView!
    @IBOutlet weak var colorIndicatorView: UIView!  // Indicates the selected color

    // MARK: - Delegate
    var delegate: CameraViewControllerDelegate?
    
    //MARK:- Properties
    // Computed property that has all the text fields added in camera control view
    fileprivate var textFields: [UITextField] {
        get {
            var textFields: [UITextField] = []
            for view in photoEditView.subviews {
                //grab textfields
                if let textField = view as? UITextField {
                    textFields.append(textField)
                }
            }
            return textFields
        }
    }
    
    fileprivate var metadata: [String: AnyObject?]? // meta data for the picture
    
    // Image pickers are not currently in use because AVCaptureSession is in use for full screen view
    fileprivate var imagePicker: UIImagePickerController?
    fileprivate var imagePickerView: UIView?
    
    fileprivate var colorSlider: ColorSlider?   // Color slider to change color
    
    // Detect current mode
    fileprivate var isCameraMode: Bool?
    fileprivate var isEditingMode: Bool?
    
    // To store current font size for pinch gesture scaling
    fileprivate var currentFontSize: CGFloat?
    fileprivate var lastRotation: CGFloat = 0
    
    // To store original center position for panned gesture
    fileprivate var originalCenter: CGPoint?
    
    // AVCapturePhotoOutput
    var captureSession: AVCaptureSession?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Drawing
    // https://www.raywenderlich.com/87899/make-simple-drawing-app-uikit-swift
    var lastPoint = CGPoint.zero
    // TODO: Move these to Constants.swift
    var lineWidth: CGFloat = 7.0
    //var context: CGContext?
    var isDrawing = false
    var isDrawingAdded = false
    var drawingImageView: UIImageView?
    var imageScale: CGFloat = 0 // scaling for image context
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedBackground(_:)))
        photoEditView.addGestureRecognizer(tap)
        
        metadata = ["missing metadata" : "you didn't add metadata for this picture" as Optional<AnyObject>]
        
        setupButtons()
        setupCaptureSession()
        setupColorSlider()
        setupColorIndicatorView()
        enterCameraMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // cameraView resizes incorrectly for some reason.
        // At first call, cameraView.bounds is (0.0, 0.0, 375.0, 667.0)
        // At second call, cameraView.bounds is (0.0, 0.0, 414.0, 736.0)
        // Use UIScreen.main.bounds instead
        //previewLayer?.frame = cameraView.bounds
        previewLayer?.frame = UIScreen.main.bounds
    }
    
    private func setupButtons() {
        // Button Configuration
        addButton.tintColor = Styles.Color.Tertiary
        locationButton.delegate = self
        cancelButton.tintColor = Styles.Color.Tertiary
    }
    
    private func setupColorSlider() {
        colorSlider = ColorSlider()
        colorSlider!.frame = CGRect(x: 0, y: 0, width: colorSliderView.frame.width, height: colorSliderView.frame.height+20)
        colorSlider!.borderWidth = 2.0
        colorSlider!.borderColor = UIColor.white
        colorSliderView.addSubview(colorSlider!)
        colorSlider!.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    
    private func setupColorIndicatorView() {
        colorIndicatorView.backgroundColor = colorSlider?.color
        colorIndicatorView.layer.cornerRadius = 5
        colorIndicatorView.layer.masksToBounds = true
        colorIndicatorView.layer.borderColor = UIColor.white.cgColor
        colorIndicatorView.layer.borderWidth = 2.0
    }
    
    @objc private func changedColor(_ slider: ColorSlider) {
        
        let color = slider.color
        if isEditing {
            for textField in textFields {
                if textField.isEditing {
                    textField.textColor = color
                }
            }
        }
        
        colorIndicatorView.backgroundColor = slider.color
        
    }
    
    // MARK: Mode switching
    private func enterCameraMode() {
        cameraView.isHidden = false
        photoEditView.isHidden = true
        captureSession?.startRunning()
        drawingImageView?.image = nil
        isEditingMode = false
        isCameraMode = true
        delegate?.showTitleScrollView()
        delegate?.showTabBar()
    }
    
    fileprivate func enterEditMode() {
        cameraView.isHidden = true
        photoEditView.isHidden = false
        captureSession?.stopRunning()
        isCameraMode = false
        isEditingMode = false
        delegate?.hideTitleScrollView()
        delegate?.hideTabBar()
    }
    
    @IBAction func onUpload(_ sender: UIButton) {
        
        let busy = BusyView()
        busy.view.center = self.view.center
        self.view.addSubview(busy)
        busy.startAnimating()
        
        // Combine all the component: drawings, texts, and the image
        merge()
        //drawItemsToImage()
        
        // Resize the image
        var localID: String!
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: self.mainImageView.image!)
            localID = (creationRequest.placeholderForCreatedAsset?.localIdentifier)!
        }, completionHandler: { (success, error) in
            let phAssets = PHAsset.fetchAssets(withLocalIdentifiers: [localID], options: nil)
            let imageSize = self.mainImageView.image!.size
            
            // Why is scaling needed?
            //let scale: CGFloat = Constants.ImageCompressionAndResizingRate.resizingScale
            //let targetSize = CGSize(width: imageSize!.width * scale, height: imageSize!.height * scale)
            let targetSize = imageSize
            
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
        mainImageView.image = nil
    }
    
    // MARK: Button Actionss
    @IBAction func onCancel(_ sender: UIButton) {
        removeAllItems()
        enterCameraMode()
    }
    
    //MARK: - Manging Textfeld methods
    @IBAction func tappedAddTextButton(_ sender: Any) {
        addNewTextFieldToCameraControlView()
    }

    // MARK: Drawing
    
    // Draw button clicked
    @IBAction func onDraw(_ sender: Any) {
        if !isDrawing {
            // start drawing
            // set isDrawing true
            isDrawing = true
            isDrawingAdded = true
            
            // setup drawingImageView
            drawingImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: mainImageView.frame.width, height: mainImageView.frame.height))
            // insert it on editImageView at index of 1
            photoEditView.insertSubview(drawingImageView!, at: 1)
            if let pageViewController = parent as? PageViewController {
                pageViewController.disableScrolling()
            }
            
        } else {
            // stop drawing
            // set isDrawing true
            isDrawing = false
            if let pageViewController = parent as? PageViewController {
                pageViewController.enableScrolling()
            }
        }
        print(photoEditView.subviews)
    }
    
    /**
     Called when you are about to touch the screen. 
     Stores the point you have touched to use it as the starting point of a line.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawing {
            if let touch = touches.first {
                lastPoint = touch.location(in: view)
            }
        }
    }
    
    /**
     Draw a line from a point to another point on an image view. This method is called everytime touchesMoved is called
     */
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        if isDrawing {
            // 1 Start a context with the size of drawingImageView
            //UIGraphicsBeginImageContext(mainImageView!.frame.size)
            UIGraphicsBeginImageContextWithOptions(drawingImageView!.frame.size, false, imageScale)
            if let context = UIGraphicsGetCurrentContext() {
                drawingImageView?.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
                
                // 2 Add a line segment from lastPoint to currentPoint.
                context.move(to: fromPoint)
                context.addLine(to: toPoint)
                
                // 3 Setup some preferences
                context.setLineCap(CGLineCap.round)
                context.setLineWidth(lineWidth)
                context.setStrokeColor(colorSlider!.color.cgColor)
                context.setBlendMode(CGBlendMode.normal)
                
                // 4 Draw the path
                context.strokePath()
                
                // 5 Apply the path to drawingImageView
                drawingImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext()
        }
        
        // Directly draw into main image view.
        // If you draw drawing image view and
    }
    
    /**
     Called when you move fingers on the screen. Holds the point before the finger moves and after it has moved
     and draws a line between them.
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if drawing mode is on
        if isDrawing {
            if let touch = touches.first {
                let currentPoint = touch.location(in: view)
                
                // 6 Pass last point and current point into drawLine
                drawLine(fromPoint: lastPoint, toPoint: currentPoint)
                
                // 7 Assign the current point to last point
                lastPoint = currentPoint
                
            }
        }
    }
    
    /**
     Render drawn image view into picture image view
    */
    private func add(drawing: UIImageView, to image: UIImageView) {
        if let drawingImageView = drawingImageView {
            // Merge tempImageView into mainImageView
            //UIGraphicsBeginImageContext(mainImageView.frame.size)
            UIGraphicsBeginImageContextWithOptions(mainImageView.frame.size, false, imageScale)
            mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            drawingImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            drawingImageView.image = nil
        }
    }
    
    
    /**
     Draw text and drawing into image
    */
    private func merge() {
        if isDrawingAdded {
            add(drawing: drawingImageView!, to: mainImageView)
        }
        
        if textFields.count > 0 {
            add(textFields: textFields, to: mainImageView.image!)
        }
    }
    
    
    /**
     Draw text and image into main image in the same context at the same time
    */
    // TODO: fix. text won't show up. unnecessary zoom happens
    private func drawItemsToImage() {
        
        // Begin context
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        
        // add texts
        if textFields.count > 0 {
            let scaleScreenToImageWidth = mainImageView.image!.size.width / mainImageView.frame.width
            let scaleScreenToImageHeight = mainImageView.image!.size.height / mainImageView.frame.height
            
            mainImageView.image!.draw(in: CGRect(origin: CGPoint.zero, size: mainImageView.image!.size))
            
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
                let textColor = textField.textColor
                let fontSize = textField.font?.pointSize
                let textFont = UIFont(name: "Helvetica", size: fontSize! * scaleScreenToImageWidth)!
                let textFontAttributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
                
                // Draw text in rect
                let rect = CGRect(origin: textLabelPointInImage, size: mainImageView.image!.size)
                
                textNSString.draw(in: rect, withAttributes: textFontAttributes)
            }
        }
        
        // add drawings
        if let drawingImageView = drawingImageView {
            drawingImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            drawingImageView.image = nil
        }
        
        // Get the final result and end the context
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

}

// MARK: Text Field
extension CameraViewController: UITextFieldDelegate {
    
    // MARK: Add Text To Image
    fileprivate func add(textFields: [UITextField], to image: UIImage) {
        
        let scaleScreenToImageWidth = image.size.width / mainImageView.frame.width
        let scaleScreenToImageHeight = image.size.height / mainImageView.frame.height
        
        // Configure context
        UIGraphicsBeginImageContextWithOptions(image.size, false, imageScale)
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
            let textColor = textField.textColor
            let fontSize = textField.font?.pointSize
            let textFont = UIFont(name: "Helvetica", size: fontSize! * scaleScreenToImageWidth)!
            let textFontAttributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
            
            // Draw text in rect
            let rect = CGRect(origin: textLabelPointInImage, size: image.size)
            
            textNSString.draw(in: rect, withAttributes: textFontAttributes)
        }
        
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
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
        textField.center = photoEditView.center
        textField.keyboardType = UIKeyboardType.default
        photoEditView.addSubview(textField)
        photoEditView.insertSubview(textField, at: view.subviews.count)
        
        textField.becomeFirstResponder()
    }
    
    // MARK: Gestures
    // http://stackoverflow.com/questions/13669457/ios-scaling-uitextview-with-pinching
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
            
            let translation = sender.translation(in: photoEditView)
            sender.view?.center = CGPoint(x: originalCenter!.x + translation.x , y: originalCenter!.y + translation.y)
            
        } else if sender.state == UIGestureRecognizerState.ended {
            
        }
        
    }
    
    // Tapped on background: end editing on all textfields
    @objc fileprivate func tappedBackground(_ sender: UITapGestureRecognizer) {
        photoEditView.endEditing(true)
    }
    
    fileprivate func removeTextfieldFromSubbiew() {
        for view in photoEditView.subviews {
            if let textField = view as? UITextField {
                textField.removeFromSuperview()
            }
        }
    }
    
    // MARK: Delegate methods
    // On change resize the view
    @objc private func textFieldDidChange(_ sender: UITextField) {
        sender.sizeToFit()
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: image picker (Not being used. Instead AVCaptureSession is used for full screen)
//extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
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
//            mainImageView.image = image
//            enterEditMode()
//        }
//    }
//}

// MARK: AVCaptureSession
// https://www.youtube.com/watch?v=994Hsi1zs6Q&t=3s
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    /** 
     Setup full screen camera preview
    */
    fileprivate func setupCaptureSession() {
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
    
    // MARK: Delegate methods
    internal func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        let dataProvider = CGDataProvider(data: imageData as! CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
        self.mainImageView.image = image
        enterEditMode()
    }
    
    /**
     This method is called from tab view controller because shutter button is in tab view controller.
     */
    internal func takePicture() {
        if isCameraMode! {
            if let videoConnection = photoOutput?.connection(withMediaType: AVMediaTypeVideo) {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])
                photoOutput?.capturePhoto(with: settings, delegate: self)
                
            }
        }
    }
}

// MARK: Button delegate
extension CameraViewController: LocationButtonDelegate {
    internal func locationButton(yelpDidSelect restaurant: Restaurant) {
        metadata = restaurant.dictionary
    }
    
    internal func locationButton(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> ())?) {
        present(viewControllerToPresent, animated: true, completion: {
        })
    }
}
