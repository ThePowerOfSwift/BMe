//
//  Camera.swift
//  RealTimeFilteringSwift
//
//  Created by Satoru Sasozaki on 2/16/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit // OpenGL

// For saving gif to camera roll
import ImageIO
import MobileCoreServices
import Photos

// TODO: check camera device is available

// TODO: Reduce CIImage size when storing to array
// TODO: Clean up applying filter and fixing orientation part

protocol SatoCameraOutput {
    // set outputImageView with filtered image in
    // didFinishProcessingPhotoSampleBuffer when snapping
    // didSetFilter when post changing
    /** Show the filtered output image view. */
    var outputImageView: UIImageView? { get set}
    // set is needed because rotating UIView needs UIImageView. UIImage rotating won't work
    
    /** Show the live preview. GLKView is added to this view. */
    var sampleBufferView: UIView? { get }
}

/** Client of this class has to do
 1. Initialize with frame the client will use for preview
 2. Set delegate to self
 3. Implement delegate methods
 4. Call start() to start running camera
 5. Call capturePhoto() to take a photo. Receive the result image view in receive(filteredImageView:unfilteredImageView:)
 6. Call startRecordingGif() and endRecordingGif(completion:) to record gif
 */
class SatoCamera: NSObject {
    
    /** view where CIImage created from sample buffer in didOutputSampleBuffer() is shown. Updated real time. */
    fileprivate var videoPreview: GLKView?
    fileprivate var videoDevice: AVCaptureDevice?
    /** needed for real time image processing. instantiated with EAGLContext. */
    fileprivate var ciContext: CIContext?
    fileprivate var eaglContext: EAGLContext?
    fileprivate var videoPreviewViewBounds: CGRect?
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var photoOutput: AVCapturePhotoOutput?
    
    fileprivate static let resizingImageScale: CGFloat = 0.3
    fileprivate static let imageViewAnimationDuration = 2.0
    
    /** array of unfiltered CIImage from didOutputSampleBuffer.
     Filter should be applied when stop recording gif but not real time
     because that slows down preview. */
    fileprivate var unfilteredCIImages: [CIImage] = [CIImage]()
    /** Check if gif is generated. */
    fileprivate var isGif: Bool = false
    
    fileprivate var unfilteredCIImage: CIImage?
    
    /** count variable to count how many times the method gets called */
    fileprivate var count: Int = 0
    /** video frame will be captured once in the frequency how many times didOutputSample buffer is called. */
    fileprivate static let frameCaptureFrequency: Int = 10
    
    /** Indicates if SatoCamera is recording gif.*/
    fileprivate var isRecording: Bool = false
    
    /** Frame of preview view in a client. Should be set when being initialized. */
    fileprivate var frame: CGRect
    
    /** Can be set after initialization. videoPreview will be added subview to sampleBufferOutput in dataSource. */
    var cameraOutput: SatoCameraOutput? {
        didSet {
            
            guard let videoPreview = videoPreview, let cameraOutput = cameraOutput else {
                print("video preview or camera output is nil")
                return
            }
            
            guard let sampleBufferOutput = cameraOutput.sampleBufferView else {
                print("sample buffer view is nil")
                return
            }
            
            for subview in sampleBufferOutput.subviews {
                subview.removeFromSuperview()
            }
            
            sampleBufferOutput.addSubview(videoPreview)
            print("video preview is set to sample buffer output as a subview")
            
        }
    }
    
    /** Store filter name. Changed by a client through change(filterName:). */
    private var filterName: String = "CISepiaTone"
    
    /** Holds the current filter. */
    var currentFilter: Filter = Filter.list()[0]
    
    convenience init(frame: CGRect) {
        self.init(frame: frame, cameraOutput: nil)
    }
    
    init(frame: CGRect, cameraOutput: SatoCameraOutput?) {
        self.frame = frame
        //http://stackoverflow.com/questions/29619846/in-swift-didset-doesn-t-fire-when-invoked-from-init
        // didSet in cameraOutput is not called here before super.init() is called
        self.cameraOutput = cameraOutput

        super.init()

        // EAGLContext object manages an OpenGL ES rendering context
        eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        guard let eaglContext = eaglContext else {
            print("eaglContext is nil")
            return
        }
        
        // Configure GLK preview view.
        // GLKView is A default implementation for views that draw their content using OpenGL ES.
        videoPreview = GLKView(frame: frame, context: eaglContext)
        guard let videoPreview = videoPreview else {
            print("videoPreviewView is nil")
            return
        }
        
        videoPreview.enableSetNeedsDisplay = false
        
        // the original video image from the back SatoCamera is landscape. apply 90 degree transform
        videoPreview.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        
        // Always set frame after transformation
        videoPreview.frame = frame
        
        videoPreview.bindDrawable()
        videoPreviewViewBounds = CGRect.zero
        videoPreviewViewBounds?.size.width = CGFloat(videoPreview.drawableWidth)
        videoPreviewViewBounds?.size.height = CGFloat(videoPreview.drawableHeight)
        
        ciContext = CIContext(eaglContext: eaglContext)
        
        cameraOutput?.sampleBufferView?.addSubview(videoPreview)
        initialStart()
    }
    
    /** Start running capture session. */
    private func initialStart() {
        
        // Get video device
        guard let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            print("video device is nil")
            return
        }
        
        self.videoDevice = videoDevice
        
        // If the video device support high preset, set the preset to capture session
        let preset = AVCaptureSessionPresetHigh
        if videoDevice.supportsAVCaptureSessionPreset(preset) {
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = preset
        }
        
        // make class property video device
//        if videoDevice.isFocusModeSupported(AVCaptureFocusMode.autoFocus) {
//            do {
//                try videoDevice.lockForConfiguration()
//                videoDevice.focusMode = AVCaptureFocusMode.autoFocus
//                videoDevice.unlockForConfiguration()
//            } catch {
//                print("error in try catch")
//            }
//        }
        
        guard let captureSession = captureSession else {
            print("capture session is nil")
            return
        }
        
        // Configure video output setting
        let outputSettings: [AnyHashable : Any] = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = outputSettings
        
        // Ensure frames are delivered to the delegate in order
        let captureSessionQueue = DispatchQueue.main
        // Set delegate to self for didOutputSampleBuffer
        videoDataOutput.setSampleBufferDelegate(self, queue: captureSessionQueue)
        
        // Discard late video frames not to cause lag and be slow
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        // add still image output
        photoOutput = AVCapturePhotoOutput()
        
        // Minimize visibility or inconsistency of state
        captureSession.beginConfiguration()
        
        if !captureSession.canAddOutput(videoDataOutput) {
            print("cannot add video data output")
            return
        }
        
        // Configure input object with device
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            // Add it to session
            captureSession.addInput(videoDeviceInput)
        } catch {
            print("Failed to instantiate input object")
        }
        
        // Add output object to session
        captureSession.addOutput(videoDataOutput)
        captureSession.addOutput(photoOutput)
        
        // Assemble all the settings together
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        //let videoConnection = videoDataOutput.connection(withMediaType: AVMediaTypeVideo)
        //videoConnection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
    }
    
    /** Focus on where it's tapped. */
    internal func tapToFocus(touch: UITouch) {
        
        let touchPoint = touch.location(in: videoPreview)
        
        print("tap to focus: (x: \(String(format: "%.0f", touchPoint.x)), y: \(String(format: "%.0f", touchPoint.y))) in \(self)")
        let adjustedCoordinatePoint = CGPoint(x: frame.width - touchPoint.y, y: touchPoint.x)
        print("adjusted point: (x: \(String(format: "%.0f", adjustedCoordinatePoint.x)) y: \(String(format: "%.0f", adjustedCoordinatePoint.y)))")
        
        guard let videoDevice = videoDevice else {
            print("video device is nil")
            return
        }
        
        let adjustedPoint = CGPoint(x: adjustedCoordinatePoint.x / frame.width, y: adjustedCoordinatePoint.y / frame.height)
        
        if videoDevice.isFocusPointOfInterestSupported && videoDevice.isFocusModeSupported(AVCaptureFocusMode.autoFocus) && videoDevice.isExposureModeSupported(AVCaptureExposureMode.autoExpose) {
            do {
                // lock device to change
                try videoDevice.lockForConfiguration()
                // https://developer.apple.com/reference/avfoundation/avcapturedevice/1385853-focuspointofinterest
                
                // set point
                videoDevice.focusPointOfInterest = adjustedPoint
                videoDevice.exposurePointOfInterest = adjustedPoint
                
                // execute operation now
                videoDevice.focusMode = AVCaptureFocusMode.autoFocus
                videoDevice.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                
                videoDevice.unlockForConfiguration()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        // feedback rect view
        let feedbackView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        feedbackView.center = adjustedPoint
        feedbackView.layer.borderColor = UIColor.white.cgColor
        feedbackView.layer.borderWidth = 2.0
        feedbackView.backgroundColor = UIColor.clear
        cameraOutput?.sampleBufferView?.addSubview(feedbackView)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // Put your code which should be executed with a delay here
            feedbackView.removeFromSuperview()
        })
    }
    
    /** Resumes camera. */
    internal func start() {
        cameraOutput?.sampleBufferView?.isHidden = false
        
        // remove image from output view
        if let cameraOutput = cameraOutput {
            if let outputImageView = cameraOutput.outputImageView {
                for subview in outputImageView.subviews {
                    subview.removeFromSuperview()
                }
            }
        }
        reset()
        captureSession?.startRunning()
    }
    
    internal func stop() {
        cameraOutput?.sampleBufferView?.isHidden = true
        captureSession?.stopRunning()
    }
    
    /** Set to the initial state. */
    private func reset() {
        unfilteredCIImages.removeAll()
        unfilteredCIImage = nil
        isGif = false
        count = 0
    }
    
    /** Store CIImage captured in didOutputSampleBuffer into array */
    fileprivate func store(image: CIImage, to images: inout [CIImage]) {
        images.append(image)
    }
    
    internal func startRecordingGif() {
        isRecording = true
        isGif = true
    }
    
    internal func stopRecordingGif() {
        isRecording = false
        stop()
        
        guard let orientUIImages = fixOrientationAndApplyFilter(ciImages: unfilteredCIImages) else {
            print("orient uiimages is nil in \(#function)")
            return
        }
        
        guard let gifImageView = UIImageView.generateGifImageView(with: orientUIImages, frame: frame, duration: SatoCamera.imageViewAnimationDuration) else {
            print("failed to produce gif image")
            return
        }
        
        if let cameraOutput = cameraOutput {
            if let outputImageView = cameraOutput.outputImageView {
                outputImageView.isHidden = false
                for subview in outputImageView.subviews {
                    subview.removeFromSuperview()
                }
            }
        }
        
        cameraOutput?.outputImageView?.addSubview(gifImageView)
        gifImageView.startAnimating()
        
        gifImageView.saveGifToDisk(completion: { (url: URL?, error: Error?) in
            if error != nil {
                print("\(error?.localizedDescription)")
            } else if let url = url {
                
                // check authorization status
                PHPhotoLibrary.requestAuthorization
                    { (status) -> Void in
                        switch (status)
                        {
                        case .authorized:
                            // Permission Granted
                            print("Photo library usage authorized")
                        case .denied:
                            // Permission Denied
                            print("User denied")
                        default:
                            print("Restricted")
                        }
                }
                
                // save data to the url
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                }, completionHandler: { (saved: Bool, error: Error?) in
                    
                })
            }
        })
    }
}

extension SatoCamera: FilterImageEffectDelegate {
    
    func didSelectFilter(_ sender: FilterImageEffect, filter: Filter?) {
        // set filtered output image to outputImageView
        guard let captureSession = captureSession else {
            print("capture session is nil in \(#function)")
            return
        }
        
        // if camera is running, just change the filter name
        //self.filterName = filterName
        //self.filterIndex = indexPath.item
    
        guard let filter = filter else {
            print("filter is nil in \(#function)")
            return
        }
        
        self.currentFilter = filter
        
        // if camera is not running
        if !captureSession.isRunning {
            
            if isGif {
                
                guard let filteredUIImages = fixOrientationAndApplyFilter(ciImages: unfilteredCIImages) else {
                    print("filtered uiimages is nil in \(#function)")
                    return
                }
                
                guard let gifImageView = UIImageView.generateGifImageView(with: filteredUIImages, frame: frame, duration: SatoCamera.imageViewAnimationDuration) else {
                    print("failed to produce gif image")
                    return
                }
                
                if let cameraOutput = cameraOutput {
                    if let outputImageView = cameraOutput.outputImageView {
                        for subview in outputImageView.subviews {
                            subview.removeFromSuperview()
                        }
                    }
                }

                cameraOutput?.outputImageView?.addSubview(gifImageView)
                gifImageView.startAnimating()
                
            } else {
                // set outputImageView with filtered image.
                guard let unfilteredCIImage = unfilteredCIImage else {
                    print("unfilteredCIImage is nil in \(#function)")
                    return
                }
                
                guard let filteredImage = currentFilter.generateFilteredCIImage(sourceImage: unfilteredCIImage) else {
                    print("filtered image is nil")
                    return
                }
                
                let rotatedFilteredUIImage = fixOrientation(ciImage: filteredImage)

                if let cameraOutput = cameraOutput {
                    if let outputImageView = cameraOutput.outputImageView {
                        for subview in outputImageView.subviews {
                            subview.removeFromSuperview()
                        }
                    }
                }
                
                let filteredUIImageView = UIImageView(image: rotatedFilteredUIImage)
                filteredUIImageView.frame = frame
                cameraOutput?.outputImageView?.addSubview(filteredUIImageView)
            }
        }
    }
}

extension SatoCamera: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    /** Called about every millisecond. Apply filter here and output video frame to preview view.
     If recording is on, store video frame both filtered and unfiltered priodically.
     */
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        guard let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("image buffer is nil")
            return
        }
        
        let sourceImage: CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let sourceExtent: CGRect = sourceImage.extent
        
        //print("filter name: \(filterName)")
//        guard let filteredImage = Filter.generateFilteredImage(sourceCIImage: sourceImage, filterName: self.filterName) else {
//            print("filtered image is nil")
//            return
//        }
        guard let filteredImage = currentFilter.generateFilteredCIImage(sourceImage: sourceImage) else {
            print("filtered image is nil")
            return
        }
        
        count += 1
        if isRecording && count % SatoCamera.frameCaptureFrequency == 0 {
            // For post filter editing. Storing two images causes lag to preview screen.
            store(image: sourceImage, to: &unfilteredCIImages)
        }
        
        let sourceAspect = sourceExtent.width / sourceExtent.height
        
        guard let videoPreviewViewBounds = videoPreviewViewBounds else {
            print("videoPreviewViewBounds is nil")
            return
        }
        
        // we want to maintain the aspect radio of the screen size, so we clip the video image
        let previewAspect = videoPreviewViewBounds.width / videoPreviewViewBounds.height
        
        var drawRect: CGRect = sourceExtent
        
        if sourceAspect > previewAspect {
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0
            drawRect.size.width = drawRect.size.height * previewAspect
        } else {
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0
            drawRect.size.height = drawRect.size.width / previewAspect
        }
        
        videoPreview?.bindDrawable()
        
        // Prepare CIContext with EAGLContext
        if eaglContext != EAGLContext.current() {
            EAGLContext.setCurrent(eaglContext)
        }
        
        // OpenGL official documentation: https://www.khronos.org/registry/OpenGL-Refpages/es2.0/
        // clear eagl view to grey
        glClearColor(0.5, 0.5, 0.5, 1.0) // specify clear values for the color buffers
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT)) // clear buffers to preset values
        // set the blend mode to "source over" so that CI will use that
        glEnable(GLenum(GL_BLEND)) // glEnable — enable or disable server-side GL capabilities
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA)) // specify pixel arithmetic
        
        ciContext?.draw(filteredImage, in: videoPreviewViewBounds, from: drawRect)
        
        // This causes runtime error with no log sometimes. That's because setNeedsDisplay is being called on a background thread, according to http://stackoverflow.com/questions/31775356/modifying-uiview-above-glkview-causing-crashes
        /*
         -display should be called when the view has been set to ignore calls to setNeedsDisplay. This method is used by
         the GLKViewController to invoke the draw method. It can also be used when not using a GLKViewController and custom
         control of the display loop is needed.
         */
        // http://stackoverflow.com/questions/26082262/exc-bad-access-with-glteximage2d-in-glkviewcontroller
        // http://qiita.com/shu223/items/2ef1e8901e96c65fd155
        videoPreview?.display()
        
        // error fixed. Had to use the main queue
        // http://dev.classmethod.jp/smartphone/iphone/swiftiphone-camera-filter/
    }
    
    /** Captures an image. Fires didFinishProcessingPhotoSampleBuffer to get image. */
    internal func capturePhoto() {
        
        // TODO: Research
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        
        settings.previewPhotoFormat = previewFormat
        
        guard let photoOutput = photoOutput else {
            print("photo output is nil")
            return
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /** get video frame and convert it to image. */
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        } else if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            guard let sourceImage = CIImage(data: dataImage) else {
                print("CIImage is nil")
                return
            }
            
            // Save sourceImage to class property for post filter editing
            unfilteredCIImage = sourceImage
            
            guard let filteredImage = currentFilter.generateFilteredCIImage(sourceImage: sourceImage) else {
                print("filtered image is nil")
                return
            }
            
            // set orientation right or left and rotate it by 90 or -90 degrees to fix rotation
            guard let rotatedUIImage = fixOrientation(ciImage: filteredImage) else {
                print("rotatedUIImage is nil in \(#function)")
                return
            }
            
            // Save to camera roll
            //UIImageWriteToSavedPhotosAlbum(filteredUIImage, nil, nil, nil)
            UIImageWriteToSavedPhotosAlbum(rotatedUIImage, nil, nil, nil)
            
            let filteredImageView = UIImageView(image: rotatedUIImage)
            filteredImageView.frame = frame
            
            // client setup
            cameraOutput?.outputImageView?.addSubview(filteredImageView)

            stop()
        }
    }
    
    /** Fixes orientation of array of CIImage and apply filters to it. 
     Fixing orientation and applying filter have to be done at the same time
     because fixing orientation only produces UIImage with its CIImage property nil.
     */
    func fixOrientationAndApplyFilter(ciImages: [CIImage]) -> [UIImage]? {
        var rotatedUIImages = [UIImage]()
        
        for ciImage in ciImages {
            
            guard let filteredCIImage = currentFilter.generateFilteredCIImage(sourceImage: ciImage) else {
                print("filtered image is nil")
                return nil
            }
            
            let filteredUIImage = UIImage(ciImage: filteredCIImage, scale: 0, orientation: UIImageOrientation.right)
            
            guard let rotatedImage = rotate(image: filteredUIImage) else {
                print("rotatedImage is nil in \(#function)")
                return nil
            }
            rotatedUIImages.append(rotatedImage)
        }
        
        return rotatedUIImages
    }
    
    /** Fixes orientation of CIImage and returns UIImage.
     Set orientation right or left and rotate it by 90 or -90 degrees to fix rotation. */
    func fixOrientation(ciImage: CIImage) -> UIImage? {
        // set orientation right or left and rotate it by 90 or -90 degrees to fix rotation
        let filteredUIImage = UIImage(ciImage: ciImage, scale: 0, orientation: UIImageOrientation.right)
        guard let rotatedImage = rotate(image: filteredUIImage) else {
            print("rotatedImage is nil in \(#function)")
            return nil
        }
        
        return rotatedImage
    }
    
    /** Rotates image by 90 degrees. */
    func rotate(image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("context is nil in \(#function)")
            return nil
        }
        image.draw(at: CGPoint.zero)
        context.rotate(by: CGFloat(M_PI_2)) // M_PI_2 = pi / 2 = 90 degrees (pi radians = 180 degrees)
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
}

/** The methods that handle only CIImage are in this extension. */
extension CIImage {
    // Apply filter to array of CIImage
    class func applyFilter(to images: [CIImage], filter: Filter) -> [CIImage] {
        var newImages = [CIImage]()

        for image in images {
            
            guard let newImage = filter.generateFilteredCIImage(sourceImage: image) else {
                print("filtered image is nil")
                break
            }
            
            newImages.append(newImage)
        }
        return newImages
    }
}

extension GLKView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began")
    }
}

/** All the methods that handle UIImage are in this extension. */
extension UIImage {
    
    /** Resize UIImage to the specified size with scale. size will be multiplied by scale.
     For exmple if you pass self.view with scale 0.7, the actual size will be self.view * 0.7.*/
    func resize(width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage
    }
    
    // TODO: Use Core Graphics resizing instead of UIKit for performance: http://nshipster.com/image-resizing/
    /** resize images to the specified size and scale so that it won't take much memory. */
    class func resizeImages(_ images :[UIImage]?, frame: CGRect) -> [UIImage]? {
        guard let images = images else {
            print("images is nil")
            return nil
        }
        
        // Array to store resized images
        var newImages: [UIImage] = [UIImage]()
        
        // Resize images
        for image in images {
            print("image size before resizing: \(image.size)")
            // Resize image to screen size * resizingImageScale (0.7) to reduce memory usage
            if let newImage = image.resize(width: frame.width, height: frame.height, scale: SatoCamera.resizingImageScale) {
                newImages.append(newImage)
                print("image size after resizing: \(newImage.size)")
                
            } else {
                print("newImage is nil")
            }
        }
        return newImages
    }
    
    // Convert array of CIImage to array of UIImage
    class func convertToUIImages(from ciImages: [CIImage]) -> [UIImage] {
        var uiImages = [UIImage]()
        for ciImage in ciImages {
            let uiImage = UIImage(ciImage: ciImage)
            uiImages.append(uiImage)
        }
        return uiImages
    }
    
    /** Generates array of UIImage from array of CIImage. Applies filter and resizes to specific frame. */
    class func generateFilteredUIImages(sourceCIImages: [CIImage], with frame: CGRect, filter: Filter) -> [UIImage] {
        
        let filteredCIImages = CIImage.applyFilter(to: sourceCIImages, filter: filter)
        let filteredUIImages = UIImage.convertToUIImages(from: filteredCIImages)
        
        guard let resizedFilteredUIImages = UIImage.resizeImages(filteredUIImages, frame: frame) else {
            print("failed to resize filtered UIImages")
            return filteredUIImages
        }
        
        //let resizedFilteredUIImages = filteredUIImages
        return resizedFilteredUIImages
    }
    
    /** Rotate UIImage by 90 degrees. This works when UIImage orientation is set to right or left.
     Output UIImage orientation is up. */
    // http://stackoverflow.com/questions/1315251/how-to-rotate-a-uiimage-90-degrees
    func rotate() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("context is nil in \(#function)")
            return nil
        }
        context.rotate(by: CGFloat(M_PI_2))
        self.draw(at: CGPoint.zero)
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
}

extension UIImageView {
    // TODO: add method that plays gif in UIImageView https://github.com/bahlo/SwiftGif
    
    /** Generate animated image view with UIImages for gif. Call startAnimating() to play. */
    class func generateGifImageView(with images: [UIImage]?, frame: CGRect, duration: TimeInterval) -> UIImageView? {
        guard let images = images else {
            print("images are nil")
            return nil
        }
        
        let gifImageView = UIImageView()
        gifImageView.animationImages = images
        gifImageView.animationDuration = duration
        // repeat count 0 means infinite repeating
        gifImageView.animationRepeatCount = 0
        // images passed from didOutputSampleBuffer is landscape by default. so it has to be rotated by 90 degrees.
        //gifImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        gifImageView.frame = frame
        return gifImageView
    }
    
    /** Creates gif data from [UIImage] and generate URL. */
    func saveGifToDisk(loopCount: Int = 0, frameDelay: Double = 0, completion: (_ data: URL?, _ error: Error?) -> ()) {
        guard let animationImages = animationImages else {
            print("animation images is nil")
            return
        }
        if animationImages.isEmpty {
            print("animationImages is empty")
            return
        }
        
        //let rotatedImages = UIImage.rotateImages(images: animationImages)
        //let rotatedImages = animationImages
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        let documentsDirectory = NSTemporaryDirectory()
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(getRandomGifFileName())
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, animationImages.count, nil) else {
            print("destination is nil")
            return
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
        
        for i in 0..<animationImages.count {
            CGImageDestinationAddImage(destination, animationImages[i].cgImage!, frameProperties as CFDictionary?)
        }
        
        if CGImageDestinationFinalize(destination) {
            completion(url, nil)
        } else {
            completion(nil, NSError())
        }
    }
    
    /** Creates gif name from time interval since 1970. */
    private func getRandomGifFileName() -> String {
        let gifName = String(Date().timeIntervalSince1970) + ".gif"
        return gifName
    }
    
    /** Take CIImage and generate UIImageView. CIImage generated in didFinishProcessing is landscape so it needs to be rotated. */
    class func generateAdjustedImageView(from sourceImage: CIImage, with frame: CGRect) -> UIImageView {
        let image = UIImage(ciImage: sourceImage)
        let imageView = UIImageView(image: image)
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        imageView.frame = frame
        return imageView
    }
}
