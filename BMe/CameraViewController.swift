//
//  CameraViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/3/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImageEditingDelegate {
    
    var image: UIImage?
    var imageURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.presentCameraPicker(timeInterval: 0.5, delegate: self, completion: {
            print("camera")
        })
    }
    
    // MARK: Image Picker
    
    func presentCameraPicker(timeInterval: TimeInterval?, delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate), completion: (() -> Void)?) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = delegate
        imagePicker.allowsEditing = false
        // Set to camera & video record
        imagePicker.sourceType = .camera
        
        // Capable for video and camera
        imagePicker.mediaTypes = [kUTTypeMovie as NSString as String, kUTTypeImage as String]
        
        // Set maximum video length, if any
        if let timeInterval = timeInterval {
            imagePicker.videoMaximumDuration = timeInterval
        }
        
        present(imagePicker, animated: true) {
            if let completion = completion { completion() }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("dictionary: \(info)")
        let imageEditingViewController = UIStoryboard(name: "Camera", bundle: nil).instantiateInitialViewController() as! ImageEditingViewController
        picker.dismiss(animated: true, completion: nil)
        
        // Delegate to return the chosen image
        imageEditingViewController.delegate = self
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = image
            
            
            if let url = info[UIImagePickerControllerReferenceURL] as? URL {
                imageURL = url
            }
            present(imageEditingViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: ImageEditingDelegate
    func getChosenImage() -> UIImage? {
        return image
    }

}




