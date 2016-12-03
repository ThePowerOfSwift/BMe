//
//  UserProfileViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 12/2/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import UIKit
import MobileCoreServices
import FirebaseStorageUI

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

@IBOutlet weak var avatarImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupAvatar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User Avatar methods
    
    // Setup profile avatar
    func setupAvatar() {
        // Avatar
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.isUserInteractionEnabled = true
        
        // Load user profile
        
        // Reference to an image file in Firebase Storage and pull image
        let defaultImage = UIImage(named: Constants.User.avatarDefault)
        let avatarRef = FIRManager.shared.storage.child((AppState.shared.currentUser?.photoURL?.path)!)
        avatarImageView.loadImageFromGS(with: avatarRef, placeholderImage: defaultImage)
        
        // Avatar tap setup
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedAvatar(_:)))
        avatarImageView.addGestureRecognizer(tap)
    }
    
    // Let user select picture or take picture as avatar
    func tappedAvatar(_ sender: UITapGestureRecognizer) {
        let prompt = UIAlertController.init(title: "Choose Profile Picture", message: "Select source", preferredStyle: .actionSheet)
        let libraryAction = UIAlertAction(title: "Library", style: .default, handler: { (action) in self.presentImagePicker(.photoLibrary)})
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {(action) in self.presentImagePicker(.camera)})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        prompt.addAction(libraryAction)
        prompt.addAction(cameraAction)
        prompt.addAction(cancel)
        present(prompt, animated: true, completion: nil);
    }
    
    func presentImagePicker(_ source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source

        if source == .camera {
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .front
        } else if source == .photoLibrary {
            imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
        }

        present(imagePicker, animated: true, completion: nil)
    }
    
    // ImagePicker delegate methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
        
        let busyIndicator = UIActivityIndicatorView(frame: avatarImageView.bounds)
        avatarImageView.addSubview(busyIndicator)
        busyIndicator.startAnimating()
        let finish = {
            busyIndicator.stopAnimating()
            busyIndicator.removeFromSuperview()
        }
        
        // Upload image as user profile pic
        if let imageData = UIImageJPEGRepresentation(pickedImage, 1) {
            FIRManager.shared.putObjectOnStorage(data: imageData, contentType: .image, completion: { (meta, error) in
                if let error = error {
                    print("Error uploading profile image to Storage: \(error.localizedDescription)")
                }
                else {
                    // Delete old profile pic
                    let oldAvatarURL = AppState.shared.currentUser?.photoURL
                    FIRManager.shared.storage.child(oldAvatarURL!.path).delete(completion: { (error) in
                        if let error = error {
                            print("Error removing old user avatar: aborted profile update: \(error.localizedDescription)")
                        }
                        // Update user profile and change avatar
                        else {
                            let changeRequest = AppState.shared.userProfileChangeRequest
                            changeRequest?.photoURL = URL(string: (meta?.gsURL)!)
                            changeRequest?.commitChanges() { (error) in
                                if let error = error {
                                    print("Error updating user profile: \(error.localizedDescription)")
                                }
                                else {
                                    self.avatarImageView.image = pickedImage
                                    finish()
                                }
                            }
                        }
                    })
                }
                finish()
            })
        }
        else { print("Error converting profile image to data- aborted upload") }
    }
}
