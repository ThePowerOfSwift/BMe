//
//  Extensions.swift
//  VideoStitch
//
//  Created by Jonathan Cheng on 11/17/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

extension UIViewController {
    // present modally camera to record
    func presentCameraPicker(timeInterval: TimeInterval?, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), completion: (() -> Void)?) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = true
        // Set to camera & video record
        imagePicker.sourceType = .camera
        imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
        
        // Set maximum video length, if any
        if let timeInterval = timeInterval {
            imagePicker.videoMaximumDuration = timeInterval
        }
        
        present(imagePicker, animated: true) {
            if let completion = completion { completion() }
        }
    }
    // TODO: - remove following two func
    // present modally camera to record
    func presentImagePicker(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), completion: (() -> Void)?) {
        let imagePicker = configuredImagePicker()
        imagePicker.delegate = delegate
        
        present(imagePicker, animated: true) {
            if let completion = completion { completion() }
        }
    }
    
    // Returns configured image picker
    func configuredImagePicker() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        
        imagePicker.allowsEditing = true
        // Set to camera & video record
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
        
        return imagePicker
    }
 
}

extension CGAffineTransform {
    func orientation() -> UIInterfaceOrientation {
        let txf = self
        
        if (txf.a == 0 && txf.b == 1.0 && txf.c == -1.0 && txf.d == 0) {
//            print("portrait")
            return .portrait
        }
        else if (txf.a == 0 && txf.b == -1.0 && txf.c == 1.0 && txf.d == 0) {
//            print("portraitUpsideDown")
            return .portraitUpsideDown
        }
        else if (txf.a == -1.0 && txf.b == 0 && txf.c == 0 && txf.d == -1.0) {
//            print("landscapeLeft")
            return .landscapeLeft
        }
        else {
//            print("landscapeRight")
            return .landscapeRight }
    }
}

extension CGSize {
    static let portrait = CGSize(width: 720.0, height: 1280.0)
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(from: self)
    }
}

extension AVURLAsset {
    func exportIPodAudio(url: URL, completion:@escaping (URL)->()) {
        let session = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A)
        print("Exporting audio, file types supported\(session?.supportedFileTypes)")
        session?.outputFileType = "com.apple.m4a-audio"
        session?.outputURL = url
        session?.exportAsynchronously(completionHandler: {
            print("Success: audio export to: \(session?.outputURL)")
            completion(url)
        })
    }
}

extension UIImage {
    func add(_ text: NSString, to point: CGPoint, color: UIColor?, font: UIFont?) -> UIImage {
        // Default colour white
        var textColor = UIColor.white
        if let color = color {
            textColor = color
        }
        // Default font
        var textFont = UIFont(name: "Helvetica Bold", size: 12)!
        if let font = font {
            textFont = font
        }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        let textFontAttributes = [NSFontAttributeName: textFont,
                                  NSForegroundColorAttributeName: textColor] as [String : Any]
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let rect = CGRect(origin: point, size: self.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
/*
extension UIView: NSCopying
{
 
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let archiver = NSKeyedArchiver.archivedData(withRootObject: self)
        let copy = NSKeyedUnarchiver.unarchiveObject(with: archiver) as! UIView
        
        let widthConstraint = NSLayoutConstraint(item: copy, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)
        let heightConstraint = NSLayoutConstraint(item: copy, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)
        copy.addConstraint(widthConstraint)
        copy.addConstraint(heightConstraint)
 
        return copy
    }
 
}
 */
