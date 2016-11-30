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
    let photoURLs: [URL]
    let videoOutputURL:URL
    var videoWriter: AVAssetWriter?
    
    init(photoURLs: [URL], videoOutputURL:URL) {
        self.photoURLs = photoURLs
        self.videoOutputURL = videoOutputURL
    }
    
    func build(progress: @escaping ((Progress) -> Void), completion: @escaping ((URL?, Error?) -> Void)) {
        let inputSize = CGSize(width: 3264, height: 2448)
        let outputSize = CGSize(width: 3264, height: 2448)
        var error: NSError?
        
        // Delete any existing at output URL
        if(FileManager.default.fileExists(atPath: videoOutputURL.path)) {
            do {
                try FileManager.default.removeItem(at: videoOutputURL)
            } catch let error as NSError {
                print("Error- deleting video file at \(videoOutputURL.path): \(error.localizedDescription)")
            }
        }
        
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
            
            let sourcePixelBufferAttributes: [String : Any] = [
                kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String : Float(inputSize.width),
                kCVPixelBufferHeightKey as String : Float(inputSize.height)]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: sourcePixelBufferAttributes
            )
            
            assert(videoWriter.canAdd(videoWriterInput))
            videoWriter.add(videoWriterInput)
            
            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime: kCMTimeZero)
                assert(pixelBufferAdaptor.pixelBufferPool != nil)
                
                let media_queue = DispatchQueue(label: "mediaInputQueue") //Create a serial queue
                
                videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: {
                    () -> Void in
                    let fps: Int32 = 1
                    
                    let currentProgress = Progress(totalUnitCount: Int64(self.photoURLs.count))

                    var frameCount: Int64 = 0
                    var remainingPhotoURLs = self.photoURLs
                    while (videoWriterInput.isReadyForMoreMediaData && !remainingPhotoURLs.isEmpty) {
                        let nextPhotoURL = remainingPhotoURLs.remove(at: 0)
                        let thisFrameTime = CMTimeMake(frameCount, fps)
                        let presentationTime = thisFrameTime
                        
                        if !self.appendPixelBufferForImageAtURL(url: nextPhotoURL, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
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
    
    private func appendPixelBufferForImageAtURL(url: URL, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = true
        
        autoreleasepool {
            if let imageData = NSData(contentsOf: url),
                let image = UIImage(data: imageData as Data) {
                
                if let image = resizeImage(image: image, newWidth: 3264) {
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
                } else {
                    print("Error: cannot access pixel buffer pointee")
                }
                
            } else {
                // Should pass error out of releasepool
                print("Error: cannot create image from data at url: \(url.absoluteString)")
            }
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
//        let scale = newWidth / image.size.width
        let newHeight = CGFloat(2448)//image.size.height * scale
        print("image width: \(image.size.width) -> new width \(newWidth)")
        print("image height: \(image.size.height) -> new height \(newHeight)")

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
