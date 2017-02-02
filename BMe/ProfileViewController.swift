
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
    
    
    fileprivate var _refHandle: FIRDatabaseHandle?
    fileprivate var _refHandleRemove: FIRDatabaseHandle?
    fileprivate let dbReference = FIRManager.shared.database.child(ContentType.post.objectKey()).queryOrdered(byChild: Post.Key.timestamp)
    var isFetchingData = false
    
    var posts: [FIRDataSnapshot]! = []
    var isListButtonHighlighted = MiddleMenuButton.off
    var isGridHighLighted = MiddleMenuButton.on

    
    var isTableHighLighted:Bool = false
//    var isGridHighLighted:Bool = true
    
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    
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
        
        // Observe vales for init loading and for newly added rainchecked posts
        _refHandle = UserProfile.firebasePath(UserAccount.currentUser.uid!).child(UserProfile.Key.raincheck).queryOrdered(byChild: UserProfile.Key.timestamp).observe(.childAdded, with: { (snapshot) in
            print(snapshot.key)
            let postID = snapshot.key
            FIRManager.shared.fetchPostsWithID([postID], completion: { (snapshots) in
                // data is returned chronologically, we want the reverse
                if snapshots.count > 0 {
                    self.posts.insert(snapshots.first!, at: 0)
                    self.photosCollectionView.reloadData()
                }
                // stop refresh control if was refreshed
            })
        })
        
        // Observe vales for real time removed rainchecked posts
        _refHandleRemove = UserProfile.firebasePath(UserAccount.currentUser.uid!).child(UserProfile.Key.raincheck).queryOrdered(byChild: UserProfile.Key.timestamp).observe(.childRemoved, with: { (snapshot) in
            // match up the post ID from usermeta with the post ID of
            let removedPostID = snapshot.key
            for snap in self.posts {
                if snap.key == removedPostID {
                    if let foundIndex = self.posts.index(of: snap) {
                        self.posts.remove(at: foundIndex)
                        break
                    }
                }
            }
        })
        //stop tvc batching feature
        isFetchingData = true
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
            let post = Post(posts[indexPath.row])
            let url = post.url
            //         fetch image
            FIRManager.shared.database.child(url!.path).observeSingleEvent(of: .value, with: { (snapshot) in
                let image = Image(snapshot.dictionary)
                if let url = image.gsURL {
                    cell.imageView.loadImageFromGS(url: url, placeholderImage: nil)
                }
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: 120, height: 120)
        return size
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    // table view data source methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
}
