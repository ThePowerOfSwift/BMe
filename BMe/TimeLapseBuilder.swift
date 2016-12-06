//
//  ViewController.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/13/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import AVFoundation
import UIKit

let kErrorDomain = "TimeLapseBuilder"
let kFailedToStartAssetWriterError = 0
let kFailedToAppendPixelBufferError = 1

class TimeLapseBuilder: NSObject {
    var image: UIImage
    let videoOutputURL:URL
    var videoWriter: AVAssetWriter?
    
    init(image: UIImage, videoOutputURL: URL) {
        self.image = image
        self.videoOutputURL = videoOutputURL
    }
    
    func build(progress: @escaping ((Progress) -> Void), completion: @escaping ((URL?, Error?) -> Void)) {
        
        // Delete any existing at output URL
        if(FileManager.default.fileExists(atPath: videoOutputURL.path)) {
            do {
                try FileManager.default.removeItem(at: videoOutputURL)
            } catch let error as NSError {
                print("Error- deleting video file at \(videoOutputURL.path): \(error.localizedDescription)")
            }
        }
        
        print("TimeLapse building for image: \(self.image.description)")
        print("... against screen: \(UIScreen.main.bounds)")
        
        let inputSize = self.image.size
        
        // Keep scale of image, or it will stretch
        // Assumed input will be landscape as well 4:3
        let outputSize = CGSize(width: 1440, height: 1080)

        var error: NSError?
        var videoWriter:AVAssetWriter?
        do {
            try
                videoWriter = AVAssetWriter(outputURL: videoOutputURL, fileType: AVFileTypeAppleM4A)
            
        }
        catch let error as NSError {
            print("Error creating AVAssetWriter: \(error.localizedDescription)")
        }
        
        if let videoWriter = videoWriter {
            let videoSettings: [String : Any] = [
                AVVideoCodecKey  : AVVideoCodecH264,
                AVVideoWidthKey  : outputSize.width,
                AVVideoHeightKey : outputSize.height]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            
            var transform = videoWriterInput.transform
            switch transform.orientation() {
            case .landscapeRight:
            // Rotate right 90 degrees
                print("right")
            transform = CGAffineTransform(translationX: outputSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat(M_PI) / CGFloat(2.0))
            case .portrait:
            // Maintain original transform to portrait
                print("portrait")
            break
            case .landscapeLeft:
                print("left")
            // Rotate right 270 degrees
            transform = CGAffineTransform(translationX: 0.0, y: outputSize.width)
            transform = transform.rotated(by: CGFloat(3.0 * M_PI) / CGFloat(2.0))
            case .portraitUpsideDown: // Orientation: upside down
                print("upside down")
                // Maintain original transform to upside down
            break
            case .unknown:
            // Maintain original transform
            break
            }
            
            // Set
            videoWriterInput.transform = transform
        

        
            let sourcePixelBufferAttributes: [String : Any] = [
                kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String : Float(inputSize.width),
                kCVPixelBufferHeightKey as String : Float(inputSize.height)]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            
            assert(videoWriter.canAdd(videoWriterInput))
            videoWriter.add(videoWriterInput)
            
            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime: kCMTimeZero)
                assert(pixelBufferAdaptor.pixelBufferPool != nil)
                
                let media_queue = DispatchQueue(label: "mediaInputQueue") //Create a serial queue
                
                videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: {
                    () -> Void in
                    // Fixed at 1 second
                    let fps: Int32 = 2
                    let frames: Int64 = 1
                    
                    let currentProgress = Progress(totalUnitCount: Int64(frames))

                    var frameCount: Int64 = 0
                    while (videoWriterInput.isReadyForMoreMediaData) && (frameCount <= frames){
                        let thisFrameTime = CMTimeMake(frameCount, fps)
                        let presentationTime = thisFrameTime
                        
                        if !self.appendPixelBufferForImage(self.image, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                            error = NSError(
                                domain: kErrorDomain,
                                code: kFailedToAppendPixelBufferError,
                                userInfo: ["description": "AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer",
                                           "rawError": videoWriter.error != nil ? "\(videoWriter.error)" : "(none)"])
                            // Breaks and moves to next image
                            break
                        }
                        
                        // Duration
                        frameCount += 1
                        
                        currentProgress.completedUnitCount = frameCount
                        progress(currentProgress)
                    }
                    videoWriterInput.markAsFinished()
                    videoWriter.finishWriting {
                        if error == nil {
                            completion(self.videoOutputURL, error)
                        }
                    }
                })
            } else {
                error = NSError(
                    domain: kErrorDomain,
                    code: kFailedToStartAssetWriterError,
                    userInfo: ["description": "AVAssetWriter failed to start writing: \(videoWriter.error)"]
                )
                print("AVAssetWriter failed to start writing: \(videoWriter.error)")
            }
        }
        
        if let error = error {
            completion(nil, error)
        }
    }
    
    private func appendPixelBufferForImage(_ image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = true
        
        autoreleasepool {
            
//            if let image = resizeImage(image: image, newWidth: 1440) {
                let pixelBuffer: UnsafeMutablePointer<CVPixelBuffer?> = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferAdaptor.pixelBufferPool!,
                    pixelBuffer
                )
                
                if let pixelBuffer = pixelBuffer.pointee, status == 0 {
                    
                    fillPixelBufferFromImage(image: image, pixelBuffer: pixelBuffer)
                    
                    appendSucceeded = pixelBufferAdaptor.append(
                        pixelBuffer,
                        withPresentationTime: presentationTime
                    )
                } else {
                    print("Error: Failed to allocate pixel buffer from pool")
                }
//            }
        }
        return appendSucceeded
    }
    
    private func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBuffer) {
        _ = CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: Int(4 * image.size.width),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )
        
        context?.draw(image.cgImage!, in:CGRect(x:0, y:0, width:image.size.width, height:image.size.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
    
    
    // TODO: - IS THIS NEEDED? why the resize?
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        print("image width: \(image.size.width) -> new width \(newWidth)")
        print("image height: \(image.size.height) -> new height \(newHeight)")

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        /* REMOVE ORIENTATION FROM IMAGE
        if (image.imageOrientation == UIImageOrientation.up) { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        
        let normalizedImage =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage;
        */
    }
    
    private func removeImageOrientation(_ image:UIImage) -> UIImage {
        if (image.imageOrientation == UIImageOrientation.up) { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: image.size))
        
        let normalizedImage =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage! as UIImage;
    }
 
    
}
