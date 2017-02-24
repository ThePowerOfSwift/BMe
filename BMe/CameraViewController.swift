//
//  NewCameraViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/19/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

/*protocol CameraViewControllerDatasource {
    
}*/

class CameraViewController: UIViewController, SatoCameraOutput, BubbleMenuCollectionViewControllerDatasource, BubbleMenuCollectionViewControllerDelegate {
    
    // MARK: Snap Testing
    @IBOutlet var snapButton: UIButton!
    
    func setupSnapButton() {
        snapButton.addTarget(self, action: #selector(snap(_:)), for: UIControlEvents.touchUpInside)
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(record(_:)))
        snapButton.addGestureRecognizer(longpress)
    }
    
    func snap(_ sender: UIControlEvents) {
        print("snap")
        satoCamera.capturePhoto()
    }
    
    func record(_ sender: UILongPressGestureRecognizer) {
        //print("record")
        
        if sender.state == UIGestureRecognizerState.began {
            print("begin")
            satoCamera.startRecordingGif()
        } else if sender.state == UIGestureRecognizerState.ended {
            print("end")
            satoCamera.stopRecordingGif()
        }
    }
    
    // MARK: Camera actions tesing
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func tappedCancel(_ sender: Any) {
        cancel()
    }
    
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func tappedSave(_ sender: Any) {
        save()
    }
    
    @IBOutlet weak var selfieButton: UIButton!
    @IBAction func tappedSelfie(_ sender: Any) {
        toggleSelfie()
    }
    
    @IBOutlet weak var flashButton: UIButton!
    @IBAction func tappedFlash(_ sender: Any) {
        toggleFlash()
    }
    
    func cancel() {
        
    }
    
    func save() {
        
    }
    
    func toggleSelfie() {
        
    }
    
    func toggleFlash() {
        
    }
    
    
    //***********
    
    /** Model */
    var satoCamera: SatoCamera!

    @IBOutlet var sampleBufferContainerView: UIView!
    @IBOutlet var outputImageContainerView: UIView!
    
    // MARK: SatoCameraOutput
    // Must always be behind all other views
    var sampleBufferView: UIView? = UIView()
    // Must always be on top of sampleBuffer
    var outputImageView: UIImageView? = UIImageView()

    /**
     View that holds all control views and the active effect tool; always floating.
     When an effect is active, it is moved to be the bottom backing view of controlView (under control containers)
     */
    @IBOutlet var controlView: UIView!

    // MARK: Image Effects
    /** Tracks which effect tool is currently selected in effects: [UIView] */
    var lastSelectedEffect = -1
    var selectedEffect = -1
    
    /** All the effects to be loaded */
    var effects: [AnyObject] = [FilterImageEffect(),
                                DrawImageEffectView(),
                                TextImageEffectView()]
    
    // MARK: Camera Controls & Tools
    // Tools
    /** Container view for effect tools */
    @IBOutlet var effectToolView: UIView!
    /** Container view for effect options */
    @IBOutlet var effectOptionView: UIView!
    @IBOutlet weak var effectOptionViewBottomConstraint: NSLayoutConstraint!
    /** Collection view for effect tool selection */
    var effectToolBubbleCVC: BubbleMenuCollectionViewController!
    /** Collection view for effect option selection */
    var effectOptionBubbleCVC: BubbleMenuCollectionViewController!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSatoCamera()
        setupControlView()
        setupEffects()
        setupSnapButton()
        
        // Finalize setup
        view.bringSubview(toFront: controlView)
        // Must manually select first effect
        selectFirstEffect()
        
        satoCamera.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObserver()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
    }
    
    // MARK: Setups
    
    func setupSatoCamera() {
        if let sampleBufferView = sampleBufferView {
            sampleBufferView.frame = sampleBufferContainerView.bounds
            sampleBufferView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            sampleBufferContainerView.addSubview(sampleBufferView)
        }

        if let outputImageView = outputImageView {
            outputImageView.frame = outputImageContainerView.bounds
            outputImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            outputImageContainerView.addSubview(outputImageView)
        }
        //view.bringSubview(toFront: outputImageContainerView)
        satoCamera = SatoCamera(frame: view.bounds)
        satoCamera.cameraOutput = self
    }
    
    func setupEffects() {
        // Add each effect
        for effect in effects {
            if let effect = effect as? UIView {
                effect.frame = view.bounds
                effect.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                view.addSubview(effect)
            }
            if let effect = effect as? FilterImageEffect {
                effect.delegate = satoCamera
            }
        }
    }
    
    func setupControlView() {
        // Give control view transparent background
        controlView.backgroundColor = UIColor.clear
        
        // Give menu transparent background
        effectToolView.backgroundColor = UIColor.clear
        effectOptionView.backgroundColor = UIColor.clear
        
        // Setup collection views for menu and options
        setupEffectToolBubbles()
        setupEffectOptionBubbles()
    }
    
    func setupEffectToolBubbles() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 77, height: 77)

        effectToolBubbleCVC = BubbleMenuCollectionViewController(collectionViewLayout: layout)
        effectToolBubbleCVC.datasource = self
        effectToolBubbleCVC.delegate = self
        
        addChildViewController(effectToolBubbleCVC)
        effectToolView.addSubview(effectToolBubbleCVC.view)
        effectToolBubbleCVC.view.frame = effectToolView.bounds
        effectToolBubbleCVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectToolBubbleCVC.didMove(toParentViewController: self)
    }
    
    func setupEffectOptionBubbles() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 77, height: 77)

        effectOptionBubbleCVC = BubbleMenuCollectionViewController(collectionViewLayout: layout)
        effectOptionBubbleCVC.datasource = self
        effectOptionBubbleCVC.delegate = self
        
        addChildViewController(effectOptionBubbleCVC)
        effectOptionView.addSubview(effectOptionBubbleCVC.view)
        effectOptionBubbleCVC.view.frame = effectOptionView.bounds
        effectOptionBubbleCVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectOptionBubbleCVC.didMove(toParentViewController: self)
    }
    
    // MARK: Selection
    
    func selectFirstEffect() {
        let indexPath = IndexPath(row: 0, section: 0)
        // Show selection
        effectToolBubbleCVC.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        // Trigger selection action
        effectToolBubbleCVC.delegate?.bubbleMenuCollectionViewController(effectToolBubbleCVC, didSelectItemAt: indexPath)
    }
    
    func didSelectEffect(at indexPath: IndexPath) {
        
        // If it's the same selection, do nothing
        if selectedEffect != indexPath.row {
            lastSelectedEffect = selectedEffect
            selectedEffect = indexPath.row
        }
        
        // Move selected effect view to fore
        // Remove last effect from control view
        if lastSelectedEffect >= 0, let effect = effects[lastSelectedEffect] as? UIView {
            view.insertSubview(effect, belowSubview: controlView)
        }
        // Bring selected effect view to back of control view
        if let effect = effects[selectedEffect] as? UIView {
            controlView.insertSubview(effect, at: 0)
        }
        
        // Tell tool it's been selected
        if let effect = effects[selectedEffect] as? CameraViewBubbleMenu {
            effect.didSelect?(effect)
        }
        
        loadToolOptions()
    }
     
    func loadToolOptions() {
        effectOptionBubbleCVC.collectionView?.reloadData()
    }
    
    // MARK: BubbleMenuCollectionViewControllerDatasource
    
    /** 
     Returns the contents for the applicable bubble menu collection view controller.
     */
    func bubbleMenuContent(for bubbleMenuCollectionViewController: BubbleMenuCollectionViewController) -> [BubbleMenuCollectionViewCellContent] {
        // Check which collection is asking for content, the tool menu or the options menu
        if (bubbleMenuCollectionViewController == effectToolBubbleCVC) {
            // Get the icons for all the effects
            var iconBubbleContents: [BubbleMenuCollectionViewCellContent] = []
            for effect in effects {
                if let effect = effect as? CameraViewBubbleMenu {
                    iconBubbleContents.append(effect.iconContent)
                }
            }
            return iconBubbleContents
        } else if (bubbleMenuCollectionViewController == effectOptionBubbleCVC) {
            // Return the options for the selected effect
            if let effect = effects[selectedEffect] as? CameraViewBubbleMenu {
                return effect.menuContent
            }
        }
        print("Error: BubbleMenu CVC not recognized; cannot provide menu content")
        return []
    }
    
    // MARK: BubbleMenuCollectionViewControllerDelegate

    func bubbleMenuCollectionViewController(_ bubbleMenuCollectionViewController: BubbleMenuCollectionViewController,
                                            didSelectItemAt indexPath: IndexPath) {
        // Check which collection view recieved the selection
        // Selection made on tools menu
        if (bubbleMenuCollectionViewController == effectToolBubbleCVC) {
            didSelectEffect(at: indexPath)
        }
        // Selection made on options menu
        else if (bubbleMenuCollectionViewController == effectOptionBubbleCVC) {
            if let effect = effects[selectedEffect] as? CameraViewBubbleMenu {
                effect.menu(bubbleMenuCollectionViewController, didSelectItemAt: indexPath)
            }
        }
    }
        
    // MARK: Keyboard
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // TODO: temp var
    var lastconstant: CGFloat = 0
    /** Keyboard appearance notification.  Pushes content (option menu) up to keyboard top floating */
    func keyboardWillShow(notification: NSNotification) {
        
        // See if menu should be pushed with keyboard
        if let showMenu = (effects[selectedEffect] as? CameraViewBubbleMenu)?.showsMenuContentOnKeyboard, showMenu {
            // Get keyboard animation information
            guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                print("Error: Cannot retrieve Keyboard frame from keyboard notification")
                return
            }
            guard let animationTime = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
                print("Error: Cannot retrienve animation duration from keyboard notification")
                return
            }
            
            // Save the original position
            lastconstant = effectOptionViewBottomConstraint.constant
            // Enforce the new position above keyboard
            effectOptionViewBottomConstraint.constant = keyboardFrame.height
            // Animate the constraint changes
            UIView.animate(withDuration: animationTime, animations: { 
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /** Keyboard appearance notification.  Pushes content (option menu) back to original position when no keyboard is shown */
    func keyboardWillHide(notification: NSNotification) {
        
        // See if menu should be pushed with keyboard
        if let showMenu = (effects[selectedEffect] as? CameraViewBubbleMenu)?.showsMenuContentOnKeyboard, showMenu {
            // Get keyboard animation information
            guard let animationTime = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
                print("Error: Cannot retrienve animation duration from keyboard notification")
                return
            }
            
            // Return to original position
            effectOptionViewBottomConstraint.constant = lastconstant
            // Animate the constraint changes
            UIView.animate(withDuration: animationTime, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

@objc protocol CameraViewBubbleMenu {
    /** Contents of the bubble menu */
    var menuContent: [BubbleMenuCollectionViewCellContent] { get }
    /** The icon image of the datasource */
    var iconContent: BubbleMenuCollectionViewCellContent { get }
    @objc optional var showsMenuContentOnKeyboard: Bool { get }
    
    func menu(_ sender: BubbleMenuCollectionViewController, didSelectItemAt indexPath: IndexPath)
    @objc optional func didSelect(_ sender: CameraViewBubbleMenu)
}
