//
//  ViewController.swift
//  BMe
//
//  Created by Satoru Sasozaki on 11/22/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import Photos

class testViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        
        print("test")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let referenceURL = info[UIImagePickerControllerReferenceURL] as! URL
        
        
        
        let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceURL as! URL], options: nil)
        let asset = assets.firstObject
        asset?.requestContentEditingInput(with: nil, completionHandler: { [weak self] (contentEditingInput, info) in
            let imageFile = (contentEditingInput?.fullSizeImageURL)!
            FirebaseManager.sharedInstance.upload(localURL: imageFile, success: {(downloadURL: URL) in
                print("downloadURL: \(downloadURL)")
            }, failure: {(error: Error) in
                
            })
            //                let filePath = "\(uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\((referenceURL as AnyObject).lastPathComponent!)"
            //                guard let strongSelf = self else { return }
            //                strongSelf.storageRef.child(filePath)
            //                    .putFile(imageFile!, metadata: nil) { (metadata, error) in
            //                        if let error = error {
            //                            let nsError = error as NSError
            //                            print("Error uploading: \(nsError.localizedDescription)")
            //                            return
            //                        }
            //                        strongSelf.sendMessage(withData: [Constants.MessageFields.imageURL: strongSelf.storageRef.child((metadata?.path)!).description])
            //                }
        })
        
        
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
