//
//  CameraViewController.swift
//  GPUImageObjcDemo
//
//  Created by Satoru Sasozaki on 1/26/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit
import GPUImage

// TODO: - Fix filter
// TODO: - Implement font feature
// TODO: - Tap text button, Select color, and start editing. but not start editing right away
// TODO: - Fix autolayout
// TODO: - Set button icons

// MARK: - Protocols
/**
 CameraViewDelegate protocol defines methods to show and hide things in delegate object.
 In this case, the delegate object is TabBarViewController.
 
 The reason why this class needs to have tab bar view controller as a delegate is
 to control tab bar behaviour. For example, your need to hide tab bar when you're in
 photo edit mode. You can get the reference to tab bar view controller from here by
 going up parent view controller, but there is page view controller between them and
 going through page view controller need more work to get the reference to tab bar view controller.
 Using delegate is simpler way.
 */
protocol CameraViewControllerDelegate {
    /** Show tab bar when camera mode is on. Called by camera view controller. */
    func showAllTabs()
    /** Hide tab bar when photo edit mode is on. Called by camera view controller. */
    func hideAllTabs()
    /** Shows the left and right tabs. Called when bubble collection view is shown and filter button is down. */
    func showSideTabs()
    /** Hides the left and right tabs. Called when bubble collection view is hidden and filter button is up. */
    func hideSideTabs()
    /** Shows the center tab. Called when cancel button is tapped while bubble collection view is shown, filter button is down. */
    func showCenterTab()
    /** Hides the center tab. Called nowhere but in case we need it. */
    func hideCenterTab()
}

/** Defines button types. Each UIButton from storyboard has a tag value and use it to differenciate the buttons. */
enum Button: Int {
    case Filter = 0
    case Draw
    case Text
    case Font
}

/** Takes pictures and edit. */
class CameraViewController: UIViewController {
    
    // stillCamera -> cameraFilter -> outputView.
    /** Camera device where input comes from. Passes input to filter object. */
    var stillCamera: GPUImageStillCamera?
    /** Stores the current filter index. */
    var filterIndex: Index = Index()
    /** final destination of camera input. */
    var outputView: GPUImageView?
    /** Stores filter object.*/
    let filters: [Filter] = Filter.list()
    var testfilter = GPUImageFilter()
    /** Stores color object. */
    var colors: [Color] = Color.list()
    /** Stores current color index. */
    var colorIndex: Index = Index()
    /** Stores current selected color. */
    var currentColor: UIColor = UIColor.white
    
    // Swipe recognizer shoud only be turned on during filter mode
    /** UISwipeGestureRecognizer on camera output view that detect right swipe gesture. */
    var swipeRightRecognizer: UISwipeGestureRecognizer?
    /** UISwipeGestureRecognizer on camera output view that detect left swipe gesture. */
    var swipeLeftRecognizer: UISwipeGestureRecognizer?
    
    /** Camera Frame. */
    var cameraFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    /** Image view photo to show photo taken. Hidden during camera mode. Shown during edit mode. */
    var photoImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    /** A layer to add text fields into. Shown only in edit mode. */
    var textImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    /** A layer to draw into. Shown only in edit mode. */
    var drawImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    /** Duration when filter is about to show. */
    fileprivate static let filterCollectionViewShowAnimationDuration: Double = 0.3
    /** Duration when filter name label slides in. */
    private static let filterNameLabelAnimationDuration: Double = 0.08
    /** Delay when filter name label stops at the center. */
    private static let filterNameLabelAnimationDelay: Double = 0.5
    /** Left onstraint when filter name label go out of screen. */
    private static let filterNameLabelLeftOutsideConstraint: CGFloat = -500
    /** Right onstraint when filter name label go out of screen. */
    private static let filterNameLabelRightOutsideConstraint: CGFloat = 500
    /** Center constraint when filter name is shown at the center. */
    private static let filterNameLabelCenterInsideConstraint: CGFloat = 0
    
    /** Tells which move you are in now. editMode() turns this variable. */
    var isEditMode: Bool = false
    /** Tells which move you are in now. cameraMode() turns this variable. */
    var isCameraMode: Bool = true
    
    /** Stores filter button's original bottom constraint for animation. */
    var filterButtonBottomConstraintShowValue: CGFloat?
    /** The bottom constraint of filter button when bubble collection view is shown.*/
    var filterButtonBottomConstraintWithCollectionViewValue: CGFloat = 70
    /** The bottom constraint of edit buttons when they are hidden during camera mode.*/
    var editButtonsBottomConstraintHideValue: CGFloat = -100
    /** The bottom constraint of edit buttons when they are shown during edit mode.*/
    var editButtonsBottomConstraintShowValue: CGFloat?
    /** The bottom constraint of edit buttons when they are shown and also bubble collection view during edit mode.*/
    var editButtonsBottomConstraintWithCollectionViewValue: CGFloat = 70
    /** Top constraint of bubble collection view when it is shown. */
    var bubbleCollectionViewTopConstraintShowValue: CGFloat?
    /** Top constraint of bubble collection view when it is hidden. */
    var bubbleCollectionViewTopConstraintHideValue: CGFloat?
    
    // MARK: Mode
    /** Tells if filter mode is on. During camera mode, filter mode is always on. */
    var isFilterMode: Bool = true
    /** Tells if draw mode is on. The other modes are all turned off.*/
    var isDrawMode: Bool = false
    /** Tells if text mode is on. The other modes are all turned off.*/
    var isTextMode: Bool = false
    /** Tells if font mode is on. The other modes are all turned off.*/
    var isFontMode: Bool = false
    /** Tells if bubble collection view is shown. */
    var isBubbleCollectionViewShown: Bool = false
    
    /** Holds unfiltered image to be filtered in edit mode.*/
    var unfilteredImage: UIImage?
    
    static let collectionViewCellReuseIdentifier = "BubbleCollectionViewCell"
    
    // MARK: Text field properties
    var imageScale: CGFloat = 0 // scaling for image context
    /** To store current font size for pinch gesture scaling */
    fileprivate var currentFontSize: CGFloat = 0
    /** the last rotation is the relative rotation value when rotation stopped last time,
     which indicates the current rotation */
    fileprivate var lastRotation: CGFloat = 0
    /** To store original center position for panned gesture */
    fileprivate var originalCenter: CGPoint?
    
    /** Computed property that has all the text fields added in textImageView */
    fileprivate var textFields: [UITextField] {
        get {
            var textFields: [UITextField] = []
            for view in textImageView.subviews {
                //grab textfields
                if let textField = view as? UITextField {
                    textFields.append(textField)
                }
            }
            return textFields
        }
    }
    
    // MARK: Drawing properties
    // https://www.raywenderlich.com/87899/make-simple-drawing-app-uikit-swift
    var lastPoint = CGPoint.zero
    // TODO: Move these to Constants.swift
    var lineWidth: CGFloat = 7.0
    var isDrawingAdded = false
    
    // MARK: - Delegate
    var delegate: CameraViewControllerDelegate?
    
    // MARK: Constraint
    @IBOutlet weak var filterButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButtonsBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleCollectionViewTopConstraint: NSLayoutConstraint!
    
    // MARK: filter name animation
    @IBOutlet weak var filterNameLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterNameLabel: UILabel!


    @IBOutlet weak var bubbleCollectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialScreenSetup()
        storeOriginalValuesInOutlets()
        cameraMode()
    }
    
    // MARK: Inital Setup
    
    /** Stores original values in outlets for animation. */
    private func storeOriginalValuesInOutlets() {
        filterButtonBottomConstraintShowValue = filterButtonBottomConstraint.constant
        editButtonsBottomConstraintShowValue = editButtonsBottomConstraint.constant
    }
    
    /** Called to set the first screen state. */
    private func initialScreenSetup() {
        view.backgroundColor = Styles.Color.Primary
        // Get camera frame
        cameraFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.width*4/3)
        // Initialize index object
        filterIndex = Index(numOfElement: filters.count)
        colorIndex = Index(numOfElement: colors.count)
        // Setup the UI
        setupBubbleCollectionView()
        setupFilterNameLabel()
        addSubviews()
    }
    
    /** Set bubble collection view initial state. */
    private func setupBubbleCollectionView() {
        bubbleCollectionView.dataSource = self
        bubbleCollectionView.delegate = self
        bubbleCollectionView.backgroundColor = UIColor.clear
        // Set the top constraint when collection view is hidden
        let cameraHeight = view.frame.width*4/3
        bubbleCollectionViewTopConstraintHideValue = cameraHeight - bubbleCollectionView.frame.height
        bubbleCollectionViewTopConstraint.constant = bubbleCollectionViewTopConstraintHideValue!
        
        // set the top constraint when collection view is shown
        bubbleCollectionViewTopConstraintShowValue = bubbleCollectionViewTopConstraintHideValue! + CGFloat(bubbleCollectionView.frame.height)
        view.layoutIfNeeded()
        let indexPath = IndexPath(item: 0, section: 0)
        if let cell = bubbleCollectionView.cellForItem(at: indexPath) as? BubbleCollectionViewCell {
            cell.nameLabel.textColor = UIColor.red
        }
    }
    
    /** set filter name label initial state. */
    private func setupFilterNameLabel() {
        let filter = filters[filterIndex.current]
        let name = filter.name
        animateFilterNameLabel(name: name, from: UISwipeGestureRecognizerDirection.right)
    }
    
    /** Add necessary subviews to view. */
    private func addSubviews() {
        addOutputView()
        addPhotoImageView()
        addTextImageView()
        addDrawImageView()
    }
    
    /** Sets up camera. Output view has to be initialized before calling this method. */
    private func addCameraToOutputView() {
        stillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .back)
        stillCamera!.outputImageOrientation = UIInterfaceOrientation.portrait
        
        // Casting is needed because addTarget require the parameter to conform to GPUImageOutput protocol
        // filters array is of type GPUImageOutput and not conforming to the protocol which causes compile error
        guard let newFilter = filters[filterIndex.current].filter as? GPUImageFilter
            else {
                print("Failed to create filter.")
                return
        }

        stillCamera!.addTarget(newFilter)
        newFilter.addTarget(outputView!)
        stillCamera!.startCapture()
    }
    
    /** Add swip recognizer for both swipe direction */
    private func addSwipeRecognizer() {
        // Right
        swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight(sender:)))
        if let swipeRightRecognizer = swipeRightRecognizer {
            swipeRightRecognizer.direction = UISwipeGestureRecognizerDirection.right
            view.addGestureRecognizer(swipeRightRecognizer)
        }
        // Left
        swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft(sender:)))
        if let swipeLeftRecognizer = swipeLeftRecognizer {
            swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.left
            view.addGestureRecognizer(swipeLeftRecognizer)
        }
    }
    
    /** Adds outputView to view at the index of 0 so that filter name is shown.
     Adds swipe gesture recognizer. */
    private func addOutputView() {
        outputView = GPUImageView(frame: cameraFrame)
        view.addSubview(outputView!)
        
        // Insert on top of filter collection view so that it hides under the camera view
        view.insertSubview(outputView!, at: 1)
        addCameraToOutputView()
        addSwipeRecognizer()
    }
    
    /** Adds image view to show image taken. */
    private func addPhotoImageView() {
        photoImageView = UIImageView(frame: cameraFrame)
        photoImageView.isHidden = true
        view.addSubview(photoImageView)
    }
    
    /** Add textImageView. */
    private func addTextImageView() {
        textImageView = UIImageView(frame: cameraFrame)
        textImageView.isUserInteractionEnabled = true
        textImageView.backgroundColor = UIColor.clear
        textImageView.isHidden = true
        view.addSubview(textImageView)
    }
    
    /** Add drawImageView.*/
    private func addDrawImageView() {
        drawImageView = UIImageView(frame: cameraFrame)
        drawImageView.isUserInteractionEnabled = true
        drawImageView.backgroundColor = UIColor.clear
        drawImageView.isHidden = true
        view.addSubview(drawImageView)
    }
    
//    CGSize size = CGSizeMake(desiredWidth, desiredHeight);
//    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
//    [[UIColor whiteColor] setFill];
//    UIRectFill(CGRectMake(0, 0, size.width, size.height));
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    /** Creates transparent image view */
    fileprivate func createClearImage(size: CGSize) -> UIImage? {
//        UIGraphicsBeginImageContext(size)
//        let clear = UIColor.white
//        clear.setFill()
//        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        var image: UIImage? = UIImage()
//        if let contextImage = UIGraphicsGetImageFromCurrentImageContext() {
//            image = contextImage
//        } else {
//            image = nil
//        }
//        UIGraphicsEndImageContext()
//        return image
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func onEditButtons(_ sender: UIButton) {
        switch sender.tag {
        case Button.Filter.rawValue:
            filterMode()

        case Button.Draw.rawValue:
            drawMode()
            
        case Button.Text.rawValue:
            addNewTextfield()
            textMode()
            
            print("On text button")

        case Button.Font.rawValue:
            print("On font button")
            fontMode()
            
        default:
            print("default in onEditButtons")
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        cameraMode()
        
        // If color bubble is shown, hide it in camera mode to switch to filter mode
        // Need to reload collection view because the color collection view setting is different from filter
        if isBubbleCollectionViewShown && isDrawMode || isTextMode {
            filterMode()
            bubbleCollectionView.reloadData()
        }
        
        removeAllItems()
    }
    
    @IBAction func onUpload(_ sender: UIButton) {
        let busy = BusyView()
        busy.view.center = self.view.center
        self.view.addSubview(busy)
        busy.startAnimating()

        // render here
        guard let resultImage = render(), let imageData = UIImagePNGRepresentation(resultImage) else {
            print("failed to render.")
            return
        }
        
        FIRManager.shared.postObject(object: imageData, contentType: .image, meta: ["key" : "value" as Optional<AnyObject>], completion: {
            print("Upload completed")
            self.removeAllItems()
            busy.stopAnimating()
            busy.removeFromSuperview()
            self.cameraMode()
        })
    }
    
    internal func swipeGestureRecognizer(state: Bool) {
        if state {
            swipeRightRecognizer?.isEnabled = true
            swipeLeftRecognizer?.isEnabled = true
        } else {
            swipeRightRecognizer?.isEnabled = false
            swipeLeftRecognizer?.isEnabled = false
        }
    }
    
    /** Called when swiping right. Calls animate filter passing the filter name and swipe direction. */
    internal func swipedRight(sender: UISwipeGestureRecognizer) {
        
        let oldIndex = filterIndex.current
        let newIndex = filterIndex.increment()
        move(from: oldIndex, to: newIndex, direction: sender.direction)
        
    }
    
    /** Called when swiping left. Calls animate filter passing the filter name and swipe direction. */
    internal func swipedLeft(sender: UISwipeGestureRecognizer) {
        
        let oldIndex = filterIndex.current
        let newIndex = filterIndex.decrement()
        move(from: oldIndex, to: newIndex, direction: sender.direction)
        
    }
    
    /** Changes filter, animates filter name label, and scroll collection view from old index to new index. */
    internal func move(from oldIndex: Int, to newIndex: Int, direction: UISwipeGestureRecognizerDirection) {
        
        let newIndexPath = IndexPath(item: newIndex, section: 0)
        let oldIndexPath = IndexPath(item: oldIndex, section: 0)
                
        // Change selected cell to red, previous cell to black
        if let cell = bubbleCollectionView.cellForItem(at: newIndexPath) as? BubbleCollectionViewCell {
            cell.nameLabel.textColor = UIColor.red
            cell.contentImageView.layer.backgroundColor = UIColor.black.cgColor
            cell.contentImageView.layer.opacity = 0.5
        }
        if let cell = bubbleCollectionView.cellForItem(at: oldIndexPath) as? BubbleCollectionViewCell {
            cell.nameLabel.textColor = UIColor.black
            cell.contentImageView.layer.backgroundColor = UIColor.clear.cgColor
            cell.contentImageView.layer.opacity = 1
        }
        
        changeFilter(newFilterIndex: newIndex)
        let name = filters[newIndex].name
        animateFilterNameLabel(name: name, from: direction)
        
        // Scroll the selected cell to center
        bubbleCollectionView.scrollToItem(at: newIndexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
    }
    
    /** Changes filter with the index. Should be called from takePicture() in edit mode.
     Creats a new instance of filter using filters[newFilterIndex].filter.
     index is needed because it is used to determine if the filtered image is cached or not during edit mode.
     caching is needed because image(byFilteringImage:) is expensive and takes time. 
     Once new filtered image is created, it is stored in filter object and used next time it gets accessed.
    */
    fileprivate func changeFilter(newFilterIndex: Int) {
        
        let newFilter = filters[newFilterIndex].filter
        
        // camera -> filter -> outputView
        if isCameraMode {
            
            if let newFilter = newFilter as? GPUImageFilterGroup {
                stillCamera?.removeAllTargets()
                stillCamera?.addTarget(newFilter)
                newFilter.addTarget(outputView!)
            } else if let newFilter = newFilter as? GPUImageFilter {
                stillCamera?.removeAllTargets()
                stillCamera?.addTarget(newFilter)
                newFilter.addTarget(outputView!)
            }
            
        } else {
            // if filtered image at the index in filter object is nil, create new filtered image and save it
            // if it exsists, use it
            
            if let cachedFilteredImage = filters[newFilterIndex].cachedFilteredImage {
                photoImageView.image = cachedFilteredImage
                print(cachedFilteredImage)
            } else {
                if let filteredImage = newFilter.image(byFilteringImage: unfilteredImage) {
                    print("newFilter: \(newFilter), filteredImage: \(filteredImage) is cached in filters[\(newFilterIndex)]")
                    filters[newFilterIndex].setFilteredImage(image: filteredImage)
                    photoImageView.image = filteredImage
                } else {
                    print("filteredImage is nil.")
                }
            }
        }
    }
    
    /** Changes filter. Using generic so that both GPUImageFilterGroup and GPUImageFilter can be passed in, 
     but restricted to a subclass of GPUImageOutput. 
     stillCamera?.capturePhotoAsImageProcessedUp(toFilter:) requires the exact same filter OBJECT to be passed in to return a captured image. */
    fileprivate func changeFilter<FilterType: GPUImageOutput>(newFilter: FilterType) {
    
        // camera -> filter -> outputView
        if isCameraMode {
            
            if let newFilter = newFilter as? GPUImageFilterGroup {
                stillCamera?.removeAllTargets()
                stillCamera?.addTarget(newFilter)
                newFilter.addTarget(outputView!)
            } else if let newFilter = newFilter as? GPUImageFilter {
                stillCamera?.removeAllTargets()
                stillCamera?.addTarget(newFilter)
                newFilter.addTarget(outputView!)
            }
            
        } else {
            
            if let filteredImage = newFilter.image(byFilteringImage: unfilteredImage) {
                photoImageView.image = filteredImage
            } else {
                print("filteredImage is nil.")
            }
            
        }
    }

    /** Calls capture on still camera object, creates UIImage, present another view controller modally. */
    internal func takePicture() {

        // Need to set the same filter to camera. Don't know why.
        let filter = GPUImageFilter()
        changeFilter(newFilter: filter)
        //changeFilter(newFilterIndex: 0)
        
        stillCamera?.capturePhotoAsImageProcessedUp(toFilter: filter, withCompletionHandler: { (image: UIImage?, error: Error?) in

            if let image = image {
                // Save the original image to unfilteredPhoto
                // Show the filtered photo in photo image view
                self.unfilteredImage = image
                self.editMode()
                self.changeFilter(newFilterIndex: self.filterIndex.current)
                self.stillCamera?.stopCapture()
                
                // let currentFilter = self.filters[self.filterIndex.current].filter
                // https://github.com/BradLarson/GPUImage/issues/1632
                // "GPUImageiOSBlurFilter imageByFilteringImage returning nil" is a major bug that hasn't been fixed yet
                // let filteredImage = currentFilter.image(byFilteringImage: image)

            } else {
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        })
    }
    
    /** Animates filter name label to specified direction. Sets name. */
    fileprivate func animateFilterNameLabel(name: String, from direction: UISwipeGestureRecognizerDirection) {
        
        // If swipe animation comes from the left side and goes to the right side
        var startConstraint: CGFloat = CameraViewController.filterNameLabelLeftOutsideConstraint
        var endConstraint: CGFloat = CameraViewController.filterNameLabelRightOutsideConstraint
        
        // If swipe animation comes from the right side and goes to the left side
        if direction == UISwipeGestureRecognizerDirection.left {
            startConstraint = CameraViewController.filterNameLabelRightOutsideConstraint
            endConstraint = CameraViewController.filterNameLabelLeftOutsideConstraint
        }
        
        // Set starting position
        filterNameLabelCenterConstraint.constant = startConstraint
        view.layoutIfNeeded()
        
        // Label first moves to the center and wait for delay time.
        UIView.animate(withDuration: CameraViewController.filterNameLabelAnimationDuration, delay: 0, options: [], animations: {
            self.filterNameLabel.text = name
            self.filterNameLabelCenterConstraint.constant = CameraViewController.filterNameLabelCenterInsideConstraint
            self.view.layoutIfNeeded()
        }) { (completed: Bool) in
            // Label moves out of screen
            UIView.animate(withDuration: CameraViewController.filterNameLabelAnimationDuration, delay: CameraViewController.filterNameLabelAnimationDelay, options: [], animations: {
                self.filterNameLabelCenterConstraint.constant = endConstraint
                self.view.layoutIfNeeded()
            }, completion: { (completed: Bool) in
            })
        }
    }
    
    /** Render drawings and texts into photo image view. */
    private func render() -> UIImage? {
        renderTextfields()
        
        UIGraphicsBeginImageContextWithOptions(photoImageView.frame.size, false, imageScale)
        if UIGraphicsGetCurrentContext() != nil {
            photoImageView.image?.draw(in: photoImageView.frame)
            drawImageView.image?.draw(in: photoImageView.frame)
            textImageView.image?.draw(in: photoImageView.frame)
            if let resultImage = UIGraphicsGetImageFromCurrentImageContext() {
                //let imageVC = ImageViewController(image: resultImage)
                //present(imageVC, animated: true, completion: {})
                return resultImage
            }
        }
        UIGraphicsEndImageContext()
        return nil
    }
}

// MARK: Mode selection
extension CameraViewController {
    // MARK: Mode Change
    /** Ready to take picrure. */
    internal func cameraMode() {
        isCameraMode = true
        isEditMode = false
        cancelButton.isHidden = true
        uploadButton.isHidden = true
        photoImageView.image = nil
        photoImageView.isHidden = true
        textImageView.image = nil
        textImageView.isHidden = true
        drawImageView.image = nil
        drawImageView.isHidden = true
        
        if isBubbleCollectionViewShown {
            delegate?.showCenterTab()
        } else {
            delegate?.showAllTabs()
        }
        
        stillCamera?.startCapture()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.editButtonsBottomConstraint.constant = self.editButtonsBottomConstraintHideValue
            self.view.layoutIfNeeded()
            
        }) { (completed: Bool) in
        }
        // Show tabs
    }
    
    /** Shows picture taken to edit. */
    internal func editMode() {
        isEditMode = true
        isCameraMode = false
        cancelButton.isHidden = false
        uploadButton.isHidden = false
        photoImageView.isHidden = false
        delegate?.hideAllTabs()
        
        view.bringSubview(toFront: photoImageView)
        view.bringSubview(toFront: cancelButton)
        view.bringSubview(toFront: uploadButton)
        view.bringSubview(toFront: filterNameLabel)
        stillCamera?.stopCapture()
        
        // Show cancel button and upload button
        // Hide tabs
        UIView.animate(withDuration: 0.2, animations: {
            if self.isBubbleCollectionViewShown {
                self.editButtonsBottomConstraint.constant = self.editButtonsBottomConstraintWithCollectionViewValue
            } else {
                self.editButtonsBottomConstraint.constant = self.editButtonsBottomConstraintShowValue!
            }
            self.view.layoutIfNeeded()
        }) { (completed: Bool) in
            
        }
    }
    
    /** Shows collection view bubble. */
    internal func bubbleMode(state: Bool) {
        // Filter editing
        if state {
            isBubbleCollectionViewShown = true
            
            // Show animation
            UIView.animate(withDuration: CameraViewController.filterCollectionViewShowAnimationDuration, animations: {
                self.bubbleCollectionView.reloadData()
                
                // Move down for the height of collection view to show it
                self.bubbleCollectionViewTopConstraint.constant = self.bubbleCollectionViewTopConstraintShowValue!
                
                // Move down the filter button
                self.filterButtonBottomConstraint.constant = self.filterButtonBottomConstraintWithCollectionViewValue
                
                if self.isEditMode {
                    // Move down the edit buttons
                    self.editButtonsBottomConstraint.constant = self.editButtonsBottomConstraintWithCollectionViewValue
                }
                self.view.layoutIfNeeded()
            })
        } else {
            
            isBubbleCollectionViewShown = false
            // Hide animation
            UIView.animate(withDuration: CameraViewController.filterCollectionViewShowAnimationDuration, animations: {
                // Move up fot the height of collection view to hide it under camera
                self.bubbleCollectionViewTopConstraint.constant = self.bubbleCollectionViewTopConstraintHideValue!
                
                // Move up the filter button
                self.filterButtonBottomConstraint.constant = self.filterButtonBottomConstraintShowValue!
                
                if self.isEditMode {
                    // Move up the edit buttons
                    self.editButtonsBottomConstraint.constant = self.editButtonsBottomConstraintShowValue!
                }
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /** Turn on filter mode with bubble. isFilterMode is always on unless draw or text mode is on. */
    internal func filterMode() {
        isDrawMode = false
        isTextMode = false
        isFontMode = false
        
        // disable the other image view user interaction to enable the current image view
        textImageView.isUserInteractionEnabled = false
        drawImageView.isUserInteractionEnabled = false
        photoImageView.isUserInteractionEnabled = true
        view.bringSubview(toFront: filterNameLabel)
        
        // Turn on swipe gesture recognizer
        swipeGestureRecognizer(state: true)
        
        if isCameraMode {
            // if it is cameraMode, then just hide or show bubble collection view
            // filter is never turned off in camera mode
            // show if bubble is hidden, hide if bubble is shown.
            bubbleMode(state: !isBubbleCollectionViewShown)
            if isBubbleCollectionViewShown {
                delegate?.hideSideTabs()
            } else {
                delegate?.showSideTabs()
            }
            
            isFilterMode = true
        } else {
            if isFilterMode {
                isFilterMode = false
                bubbleMode(state: false)
            } else {
                isFilterMode = true
                bubbleMode(state: true)
            }
        }
    }
    
    /** Enables drawing mode with bubble. */
    internal func drawMode() {
        if isDrawMode {
            isDrawMode = false
            bubbleMode(state: false)
        } else {
            
            // disable the other image view user interaction to enable the current image view
            textImageView.isUserInteractionEnabled = false
            drawImageView.isUserInteractionEnabled = true
            photoImageView.isUserInteractionEnabled = false
            
            isFilterMode = false
            isTextMode = false
            isFontMode = false
            isDrawMode = true
            view.bringSubview(toFront: drawImageView)
            view.bringSubview(toFront: cancelButton)
            view.bringSubview(toFront: uploadButton)
            drawImageView.isHidden = false
            swipeGestureRecognizer(state: false)
            bubbleMode(state: true)
        }
    }
    
    /** Enables text mode with bubble. */
    internal func textMode() {
        
        if isTextMode {
            isTextMode = false
            bubbleMode(state: false)
        } else {
            
            // disable the other image view user interaction to enable the current image view
            textImageView.isUserInteractionEnabled = true
            drawImageView.isUserInteractionEnabled = false
            photoImageView.isUserInteractionEnabled = false
            
            isFilterMode = false
            isDrawMode = false
            isFontMode = false
            isTextMode = true
            view.bringSubview(toFront: textImageView)
            view.bringSubview(toFront: cancelButton)
            view.bringSubview(toFront: uploadButton)
            textImageView.isHidden = false
            swipeGestureRecognizer(state: false)
            bubbleMode(state: true)
        }
    }
    
    // TODO: Figure out how font mode works. works with text mode?
    internal func fontMode() {
        isFilterMode = false
        isDrawMode = false
        isFontMode = false
    }
    
    /** Removes all the text, drawing, and picure. Called after cancel or upload. */
    internal func removeAllItems() {
        removeTextfieldFromSubbiew()
        textImageView.image = nil
        drawImageView.image = nil
        photoImageView.image = nil
        // set all the cached filtered image to nil
        for filter in filters {
            filter.setFilteredImage(image: nil)
        }
    }
}

// MARK: Collection view data source and delegate
extension CameraViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if isFilterMode {
            count = filters.count
        } else if isDrawMode || isTextMode {
            count = colors.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraViewController.collectionViewCellReuseIdentifier , for: indexPath) as? BubbleCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // Image view config: Circle shape. Opaque by default.
        cell.contentImageView.layer.cornerRadius = cell.contentImageView.frame.size.width / 2
        cell.contentImageView.clipsToBounds = true
        cell.contentImageView.layer.backgroundColor = UIColor.clear.cgColor
        cell.contentImageView.layer.opacity = 1
        
        cell.nameLabel.text = ""
        cell.contentImageView.image = nil
        
        if isFilterMode {
            let filter = filters[indexPath.item]
            cell.nameLabel.text = filter.name
            cell.nameLabel.textColor = UIColor.black
            
            // Set image
            let image = UIImage(named: filter.imageUrlString)
            cell.contentImageView.image = image
        } else if isDrawMode || isTextMode {
            let color = colors[indexPath.item]
            cell.contentImageView.backgroundColor = color.uiColor
            //cell.backgroundColor = color.uiColor
            cell.nameLabel.text = color.name
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFilterMode {
            
            var direction = UISwipeGestureRecognizerDirection.left
            let oldIndex = filterIndex.current
            let newIndex = indexPath.item
            // Update the index
            filterIndex.current = newIndex
            // If swiped right to decrement
            if newIndex < oldIndex {
                direction = UISwipeGestureRecognizerDirection.right
            }
            move(from: oldIndex, to: newIndex, direction: direction)
            
        } else if isDrawMode || isTextMode {
            
            colorIndex.current = indexPath.item
            currentColor = colors[colorIndex.current].uiColor
            print(currentColor)
            if let cell = collectionView.cellForItem(at: indexPath) as? BubbleCollectionViewCell {
                
                for i in 0..<collectionView.numberOfItems(inSection: 0) {
                    if i == indexPath.item {
                        //cell.contentImageView.layer.backgroundColor = UIColor.black.cgColor
                        //cell.contentImageView.layer.opacity = 0.1
                        cell.nameLabel.textColor = UIColor.red
                    } else {
                        let indexPath = IndexPath(item: i, section: 0)
                        if let otherCell = collectionView.cellForItem(at: indexPath) as? BubbleCollectionViewCell {
                            otherCell.nameLabel.textColor = UIColor.black
                        }
                        
                    }
                }
            }
        }
    }
}

// MARK: Text Field
extension CameraViewController: UITextFieldDelegate {

    /** Render texts field into text image view. */
    // TODO: Clean up
    fileprivate func renderTextfields() {

        // Configure context
        UIGraphicsBeginImageContextWithOptions(textImageView.frame.size, false, imageScale)
        textImageView.image?.draw(in: textImageView.frame)
        
        for textField in textFields {

            let textLabelPointInImage = CGPoint(x: textField.frame.origin.x, y: textField.frame.origin.y)
            
            // Text Attributes
            let textNSString = NSString(string: textField.text!)
            let textColor = textField.textColor
            let fontSize = textField.font?.pointSize
            let textFont = UIFont(name: "Helvetica", size: fontSize!)!
            let textFontAttributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
            
            // Draw text in rect
            let rect = CGRect(origin: textLabelPointInImage, size: textImageView.frame.size)
            
            textNSString.draw(in: rect, withAttributes: textFontAttributes)
        }
        
        textImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    /** Add the next text field to the screen */
    fileprivate func addNewTextfield() {
        // Create new textfield
        let textField = UITextField()
        textField.delegate = self
       
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .sentences
        textField.spellCheckingType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .done
        textField.textColor = currentColor
        textField.font = UIFont(name: "Helvetica", size: 50)
        
        // Add didedit event notifier
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        // Add double tap (to delete)
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTappedTextField(_:)))
        tap.numberOfTapsRequired = 2
        textField.addGestureRecognizer(tap)
        // Add pan (to move)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pannedTextField(_:)))
        textField.addGestureRecognizer(pan)
        
        // Add pinch gesture (to scale)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchedTextField(_:)))
        textField.addGestureRecognizer(pinch)
        
        // Add rotation gesture (to rotate)
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotatedTextField(_:)))
        textField.addGestureRecognizer(rotate)
        
        // Default appearance
        textField.attributedPlaceholder = NSAttributedString(string: "T", attributes: [NSForegroundColorAttributeName: currentColor])
        textField.sizeToFit()
        
        // Add textField to cameraControlView
        textField.center = textImageView.center
        //textField.frame = CGRect(x: textImageView.center.x, y: textImageView.center.y, width: 100, height: 50)
        textField.keyboardType = UIKeyboardType.default
        textImageView.addSubview(textField)
        textField.becomeFirstResponder()
    }
    
    // MARK: Gestures
    // http://stackoverflow.com/questions/13669457/ios-scaling-uitextview-with-pinching
    @objc private func pinchedTextField(_ sender: UIPinchGestureRecognizer) {
        if let textField = sender.view as? UITextField {
            if sender.state == .began {
                currentFontSize = textField.font!.pointSize
            } else if sender.state == .changed {
                textField.font = UIFont(name: textField.font!.fontName, size: currentFontSize * sender.scale)
                textFieldDidChange(textField)
            } else if sender.state == .ended {
                
            }
        }
    }
    
    // http://www.avocarrot.com/blog/implement-gesture-recognizers-swift/
    @objc private func rotatedTextField(_ sender: UIRotationGestureRecognizer) {
        
        var originalRotation = CGFloat()
        if sender.state == .began {
            
            // the last rotation is the relative rotation value when rotation stopped last time,
            // which indicates the current rotation
            originalRotation = lastRotation
            
            // sender.rotation renews everytime the rotation starts
            // delta value but not absolute value
            sender.rotation = lastRotation
            
        } else if sender.state == .changed {
            
            let newRotation = sender.rotation + originalRotation
            sender.view?.transform = CGAffineTransform(rotationAngle: newRotation)
            
        } else if sender.state == .ended {
            
            // Save the last rotation
            lastRotation = sender.rotation
            
        }
    }
    
    /** On double tap remove the textfield */
    @objc private func doubleTappedTextField(_ sender: UITapGestureRecognizer) {
        let textField = sender.view
        textField?.removeFromSuperview()
    }
    
    /** On pan move the textfield */
    @objc private func pannedTextField(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            originalCenter = sender.view!.center
        } else if sender.state == UIGestureRecognizerState.changed {
            
            let translation = sender.translation(in: textImageView)
            sender.view?.center = CGPoint(x: originalCenter!.x + translation.x , y: originalCenter!.y + translation.y)
            
        } else if sender.state == UIGestureRecognizerState.ended {
            
        }
    }
    
    /** Tapped on background: end editing on all textfields */
    @objc fileprivate func tappedBackground(_ sender: UITapGestureRecognizer) {
        textImageView.endEditing(true)
    }
    
    fileprivate func removeTextfieldFromSubbiew() {
        for view in textImageView.subviews {
            if let textField = view as? UITextField {
                textField.removeFromSuperview()
            }
        }
    }
    
    // MARK: Delegate methods
    /** On change resize the view */
    @objc private func textFieldDidChange(_ sender: UITextField) {
        sender.sizeToFit()
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Drawing
extension CameraViewController {
    
    /**
     Called when you are about to touch the screen.
     Stores the point you have touched to use it as the starting point of a line.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawMode {
            if let touch = touches.first {
                lastPoint = touch.location(in: view)
            }
        }
    }
    
    /**
     Draw a line from a point to another point on an image view. This method is called everytime touchesMoved is called
     */
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        if isDrawMode {
            // 1 Start a context with the size of drawingImageView
            //UIGraphicsBeginImageContext(mainImageView!.frame.size)
            UIGraphicsBeginImageContextWithOptions(drawImageView.frame.size, false, imageScale)
            if let context = UIGraphicsGetCurrentContext() {
                drawImageView.image?.draw(in: CGRect(x: 0, y: 0, width: drawImageView.frame.width, height: drawImageView.frame.size.height))
                
                // 2 Add a line segment from lastPoint to currentPoint.
                context.move(to: fromPoint)
                context.addLine(to: toPoint)
                
                // 3 Setup some preferences
                context.setLineCap(CGLineCap.round)
                context.setLineWidth(lineWidth)
                context.setStrokeColor(currentColor.cgColor)
                context.setBlendMode(CGBlendMode.normal)
                
                // 4 Draw the path
                context.strokePath()
                
                // 5 Apply the path to drawingImageView
                drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            }
            UIGraphicsEndImageContext()
        }
    }
    
    /**
     Called when you move fingers on the screen. Holds the point before the finger moves and after it has moved
     and draws a line between them.
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // if drawing mode is on
        if isDrawMode {
            if let touch = touches.first {
                let currentPoint = touch.location(in: view)
                
                // 6 Pass last point and current point into drawLine
                drawLine(fromPoint: lastPoint, toPoint: currentPoint)
                
                // 7 Assign the current point to last point
                lastPoint = currentPoint
                
            }
        }
    }
}

/** To keep track of the index of the current filter. If it reaches the end of filter array by incrementing, it goes back to 0. If it reaches 0 by decrementing, it moves to the end. */
class Index {
    
    /** Holds the end index starting 0. */
    private var count: Int = 0
    /** Holds the current index. */
    var current: Int = 0
    
    /** init with 0 element. */
    init() {
        self.count = 0
        current = 0
    }
    
    /** init with number of element and set current index to 0. */
    init(numOfElement: Int) {
        self.count = numOfElement - 1
        current = 0
    }
    
    /** Increments current by 1 and return it. If it reaches the end, it goes back to index 0. */
    internal func increment() -> Int {
        if current == count {
            current = 0
        } else {
            current = current + 1
        }
        return current
    }
    
    /** Decrements current by 1 and return it. If it reaches 0, it moves to the end. */
    internal func decrement() -> Int {
        if current == 0 {
            current = count
        } else {
            current = current - 1
        }
        return current
    }
}
