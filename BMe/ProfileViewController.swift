
//
//  ProfileViewController.swift
//  BMe
//
//  Created by parry on 1/29/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit
import MobileCoreServices
import FirebaseStorageUI
import Firebase

struct MiddleMenuButton {
    static let off = UIColor.lightGray
    static let on = UIColor.yellow
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // Model
    var user: UserProfile!
    
    //MARK: - Outlets
    @IBOutlet weak var headerProfileView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    
    @IBOutlet weak var matchupButton: UIButton!
    
    fileprivate var _refHandle: FIRDatabaseHandle?
    fileprivate var _refHandleRemove: FIRDatabaseHandle?
    var isFetchingData = false
    var posts: [FIRDataSnapshot]! = []
    
    let gridFlowLayout = PhotoGridFlowLayout()
    let listFlowLayout = PhotoListFlowLayout()
    var isGridFlowLayoutUsed: Bool = false
    
    @IBAction func tappedSignoutButton(_ sender: UIButton) {
        UserAccount.currentUser.signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide nav bar
        navigationController?.isNavigationBarHidden = true
        
        UserProfile.currentUser { (userProfile) in
            self.user = userProfile
            
            self.setupAvatar()
            self.setupUser()
            self.fetchPosts()
        }
        
        setupInitialLayout()
        view.backgroundColor = Styles.Color.Primary
        gridButton.tintColor = MiddleMenuButton.on

        // Matchup button
        FIR.manager.isModerator { (authorized) in
            print("moderator \(authorized)")
            if authorized {
                
            } else {
                
            }
        }
        
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
    
    func setupInitialLayout() {
        isGridFlowLayoutUsed = true
        photosCollectionView.collectionViewLayout = gridFlowLayout
    }
    
    //MARK: - User Avatar methods
    
    // Setup profile avatar
    func setupAvatar() {
        // Avatar
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
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
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
        
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
        // TODO: Complete using UserAccount
        // TODO: - Should move this to User.setAvatarImage()
        if let imageData = UIImageJPEGRepresentation(pickedImage, Constants.ImageCompressionAndResizingRate.compressionRate) {
            finish()
        }
        else { print("Error converting profile image to data- aborted upload") }
    
        }
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
    
    // MARK: - MiddleMenu Actions
    @IBAction func onGridButtonPressed(_ sender: UIButton) {
        listButton.tintColor = MiddleMenuButton.off
        gridButton.tintColor = MiddleMenuButton.on
        
        //switch to grid :)
        isGridFlowLayoutUsed = true
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.photosCollectionView.collectionViewLayout.invalidateLayout()
        self.photosCollectionView.setCollectionViewLayout(self.gridFlowLayout, animated: true)
        })
    }
    
    @IBAction func onTableButtonPressed(_ sender: UIButton) {
        gridButton.tintColor = MiddleMenuButton.off
        listButton.tintColor = MiddleMenuButton.on
        
        isGridFlowLayoutUsed = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.photosCollectionView.collectionViewLayout.invalidateLayout()
        self.photosCollectionView.setCollectionViewLayout(self.listFlowLayout, animated: true)
        })
        
    }
    
    // TODO: - Change to pull all posts not just rainchecks
    func fetchPosts() {
    }
    
    @IBAction func onMatchupButtonTapped(_ sender: Any) {
        presentModeratorController()
    }
    
    func presentModeratorController() {
        if let vc = UIStoryboard(name: Constants.SegueID.Storyboard.Moderator, bundle: nil).instantiateInitialViewController() {
            self.present(vc, animated: true) {
                //completion code here
            }
        }
    }
}


// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfileCollectionViewCell
        
        if posts != nil {
            //  TODO: fetch image
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    // table view data source methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
}

// MARK: - UIButton Hit Area
fileprivate let minimumHitArea = CGSize(width: 100, height: 100)

extension UIButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}
