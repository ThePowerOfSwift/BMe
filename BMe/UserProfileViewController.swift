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

class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var baseProfileView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var raincheckLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!

    @IBOutlet weak var tableViewContainer: UIView!
    
    // Deprecate
    @IBAction func tappedSignout(_ sender: Any) {
        UserAccount.currentUser.signOut()
    }
    @IBAction func tappedSignoutButton(_ sender: Any) {
        UserAccount.currentUser.signOut()
    }
    
    func setupRaincheckDB() {
        // empty call
        // cheat to trick BrowseVC to call func of same name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Hide nav bar
        navigationController?.isNavigationBarHidden = true
    
        setupAvatar()
        setupUser()
        
        // set raincheck and heart count
        UserProfile.currentUser(completion: { (userProfile) in
            if let userProfile = userProfile {
                if let raincheckCount = userProfile.raincheck?.count {
                    self.raincheckLabel.text = String(raincheckCount)
                } else {
                    self.raincheckLabel.text = String(0)
                }
                
                if let heartCount = userProfile.heart?.count {
                    self.heartLabel.text = String(heartCount)
                } else {
                    self.heartLabel.text = String(0)
                }
            }
        })
        
        view.backgroundColor = Styles.Color.Primary
        
        // TODO: - NEED TO REFACTOR TVC MODEL
        // Add tableview child vc
        let tvc = UIStoryboard(name: Constants.SegueID.Storyboard.Browser, bundle: nil).instantiateViewController(withIdentifier: Constants.SegueID.ViewController.BrowserViewController) as! BrowseViewController
        // Setup data as rainchecks
        tvc.dataSelector =  #selector(setupRaincheckDB)
        addChildViewController(tvc)
        // Configuration
        tvc.view.frame = tableViewContainer.bounds
        tvc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // TODO: - hardcoded buffer
        tvc.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        // Complete adding to containter
        tableViewContainer.addSubview(tvc.view)
        tvc.didMove(toParentViewController: self)
        
        tvc.view.backgroundColor = UIColor.clear
        tvc.tableView.backgroundColor = tvc.view.backgroundColor
        tableViewContainer.backgroundColor = UIColor.clear
        
        // tab bar reveal already embedded in child tvc above
        // Add tab bar reveal
        view.addSubview(WhiteRevealOverlayView(frame: view.bounds))
        baseProfileView.backgroundColor = Styles.Color.Primary
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User info methods
    enum Textfields: Int {
        case username = 0, email
    }
    
    // Setup user info views
    func setupUser() {
        usernameTextField.tag = Textfields.username.rawValue
        usernameTextField.delegate = self
        
        emailTextField.isUserInteractionEnabled = false
        
        emailTextField.tag = Textfields.email.rawValue
        emailTextField.delegate = self
        
        usernameTextField.text = UserAccount.currentUser.username
        emailTextField.text = UserAccount.currentUser.email
    }

    
    //MARK: - User Avatar methods
    
    // Setup profile avatar
    func setupAvatar() {
        // Avatar
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Styles.Shapes.cornerRadius
        avatarImageView.layer.borderWidth = Styles.Avatar.borderWidth
        avatarImageView.layer.borderColor = Styles.Avatar.borderColor.cgColor
        avatarImageView.isUserInteractionEnabled = true
        
        // Reference to an image file in Firebase Storage and pull image
        let defaultImage = UIImage(named: Constants.Images.avatarDefault)
        
        if let avatarURL = UserAccount.currentUser.avatarURL {
            avatarImageView.loadImageFromGS(url: avatarURL, placeholderImage: defaultImage)
        } else { avatarImageView.image = defaultImage }
        
        
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

        avatarImageView.image = pickedImage
        let busyIndicator = UIActivityIndicatorView(frame: avatarImageView.bounds)
        avatarImageView.addSubview(busyIndicator)
        busyIndicator.startAnimating()
        let finish = {
            busyIndicator.stopAnimating()
            busyIndicator.removeFromSuperview()
        }

        // Upload image as user profile pic
        // TODO: - Should move this to User.setAvatarImage()
        if let imageData = UIImageJPEGRepresentation(pickedImage, Constants.ImageCompressionAndResizingRate.compressionRate) {
            FIRManager.shared.putObjectOnStorage(data: imageData, contentType: .image, completion: { (meta, error) in
                if let error = error {
                    print("Error uploading profile image to Storage: \(error.localizedDescription)")
                }
                else {
                    // Delete old profile pic
                    if let oldAvatarURL = UserAccount.currentUser.avatarURL {
                        FIRManager.shared.storage.child(oldAvatarURL.path).delete(completion: { (error) in
                            if let error = error {
                                print("Error removing old user avatar: aborted profile update: \(error.localizedDescription)")
                            }
                        })
                    }
        
                    // Update user profile and change avatar
                    UserAccount.currentUser.avatarURL = URL(string: (meta?.storageURL)!)
                }
                finish()
            })
        }
        else { print("Error converting profile image to data- aborted upload") }
    }
    
    // MARK: - Textfield Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let newValue = textField.text
        if textField.tag == Textfields.username.rawValue {
            UserAccount.currentUser.username = newValue
        }
    }
}
