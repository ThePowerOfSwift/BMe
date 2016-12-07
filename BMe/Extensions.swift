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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        return formatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        return formatter.date(from: self)
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
    override open var description: String {
        let data = UIImageJPEGRepresentation(self, 1.0)
        let orientation: String
        switch self.imageOrientation {
        case .up: orientation = "up- default orientation"
        case .down: orientation = "down- 180 deg rotation"
        case .left: orientation = "left- 90 deg CCW"
        case .right: orientation = "right- 90 deg CW"
        case .upMirrored: orientation = "upMirrored- as above but image mirrored along other axis. horizontal flip"
        case .downMirrored: orientation = "downMirrored- horizontal flip"
        case .leftMirrored: orientation = "leftMirrored- vertical flip"
        case .rightMirrored: orientation = "rightMirrored- vertical flip"
        }
        
        return "Image info:" +
        "\t filesize: \(Float(data!.count)/(1024*1024))" +
        "\t Image size \(self.size)" +
        "\t Orientation \(orientation)"
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
