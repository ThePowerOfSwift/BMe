//
//  CameraViewController.swift
//  GPUImageObjcDemo
//
//  Created by Satoru Sasozaki on 1/26/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit
import GPUImage

// TODO: Change text color when editing by selecting bubbles

// MARK: - Protocols
/**
 CameraViewDelegate protocol defines methods to show and hide things in delegate object.
 In this case, the delegate object is TabBarViewController.
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

enum Mode: Int {
    case Camera = 0
    case Edit
    case Filter
    case Draw
    case Text
    case Font
    case Hashtag
    
    /** Change mode*/
    mutating func toggle(mode: Mode) {
        self = mode
    }
    
    /** Check the current mode*/
    func isMode(mode: Mode) -> Bool {
        return self == mode
    }
}

struct Constraint {
    
    struct FilterNameLabel {
        
        struct Outside {
            /** Left onstraint when filter name label go out of screen. */
            static let Left: CGFloat = -500
            /** Right onstraint when filter name label go out of screen. */
            static let Right: CGFloat = 500
        }
        
        struct Inside {
            /** Center constraint when filter name is shown at the center. */
            static let Center: CGFloat = 0
        }
    }
    
    struct Button {
        struct Filter {
            struct Bottom {
                /** Stores filter button's original bottom constraint for animation. */
                static var Show: CGFloat = 0
                /** The bottom constraint of filter button when bubble collection view is shown.*/
                static let ShowWithCollectionView: CGFloat = 70
            }
        }
        
        struct Edit {
            struct Bottom {
                /** The bottom constraint of edit buttons when they are shown during edit mode.*/
                static var Show: CGFloat = 0
                /** The bottom constraint of edit buttons when they are hidden during camera mode.*/
                static let Hide: CGFloat = -100
                /** The bottom constraint of filter button when bubble collection view is shown.*/
                static let ShowWithCollectionView: CGFloat = 70
            }
        }
    }
    
    struct BubbleCollectionView {
        struct Top {
            /** Top constraint of bubble collection view when it is shown. */
            static var Show: CGFloat = 0
            /** Top constraint of bubble collection view when it is shown on top of keyboard. */
            static var ShowWithKeyboard: CGFloat = 0
            /** Top constraint of bubble collection view when it is hidden. */
            static var Hide: CGFloat = 0
            
        }
    }
}

struct Animation {
    /** Duration when filter is about to show. */
    static let BubbleCollectionViewShowDuration: Double = 0.3
    /** Duration when filter name label slides in. */
    static let FilterNameLabelDuration: Double = 0.08
    /** Delay when filter name label stops at the center. */
    static let FilterNameLabelDelay: Double = 0.5
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
    
    // MARK: Mode
    /** Tells if bubble collection view is shown. */
    var isBubbleCollectionViewShown: Bool = false
    var currentMode: Mode = Mode.Camera
    
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
    
    var currentTextField: UITextField?
    
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
    
    // MARK: - Delegate
    var delegate: CameraViewControllerDelegate?
    
    // MARK: Constraint
    
    @IBOutlet weak var bubbleCollectionViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editButtonBottomConstraint: NSLayoutConstraint!
    // MARK: filter name animation
    @IBOutlet weak var filterNameLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterNameLabel: UILabel!


    @IBOutlet weak var bubbleCollectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var hashtagTextField: UITextField!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialScreenSetup()
        storeOriginalValuesInOutlets()
        toggleCameraMode()
    }
    
    // MARK: Inital Setup
    
    /** Stores original values in outlets for animation. */
    private func storeOriginalValuesInOutlets() {
        Constraint.Button.Filter.Bottom.Show = editButtonBottomConstraint.constant
        Constraint.Button.Edit.Bottom.Show = editButtonBottomConstraint.constant
    }
    
    /** Called to set the first screen state. */
    private func initialScreenSetup() {
        view.backgroundColor = Styles.Color.Primary
        // Get camera frame
        cameraFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.width*4/3)
        // Initialize index object
        filterIndex = Index(numOfElement: filters.count)
        colorIndex = Index(numOfElement: colors.count)
        
        hashtagTextField.delegate = self
        
        // Setup the UI
        setupBubbleCollectionView()
        setupFilterNameLabel()
        addSubviews()
        addKeyboardObserver()
        changeButtonTitleColor()
    }
    
    /** Set bubble collection view initial state. */
    private func setupBubbleCollectionView() {
        bubbleCollectionView.dataSource = self
        bubbleCollectionView.delegate = self
        bubbleCollectionView.backgroundColor = UIColor.clear
        // Set the top constraint when collection view is hidden
        let cameraHeight = view.frame.width*4/3
        
        // Multiply by two so that it shows on top of keyboard
        Constraint.BubbleCollectionView.Top.Hide = cameraHeight - bubbleCollectionView.frame.height * 2
        bubbleCollectionViewTopConstraint.constant = Constraint.BubbleCollectionView.Top.Hide
        
        // set the top constraint when collection view is shown
        Constraint.BubbleCollectionView.Top.Show = Constraint.BubbleCollectionView.Top.Hide + CGFloat(bubbleCollectionView.frame.height * 2)

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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedBackground(_:)))
        textImageView.addGestureRecognizer(tapGesture)
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
    
    /** Creates transparent image view */
    fileprivate func createClearImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    private func changeButtonTitleColor() {
        cancelButton.setTitleColor(Styles.Color.Tertiary, for: .normal)
        uploadButton.setTitleColor(Styles.Color.Tertiary, for: .normal)
        filterButton.setTitleColor(Styles.Color.Tertiary, for: .normal)
        drawButton.setTitleColor(Styles.Color.Tertiary, for: .normal)
        textButton.setTitleColor(Styles.Color.Tertiary, for: .normal)
        fontButton.setTitleColor(Styles.Color.Tertiary, for: .normal)
    }
    
    @IBAction func onEditButtons(_ sender: UIButton) {
        switch sender.tag {
        case Button.Filter.rawValue:
            toggleFilterMode()

        case Button.Draw.rawValue:
            toggleDrawMode()
            
        case Button.Text.rawValue:
            addNewTextfield()
            toggleTextMode()
            
            print("On text button")

        case Button.Font.rawValue:
            print("On font button")
            fontMode()
            
        default:
            print("default in onEditButtons")
        }
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        toggleCameraMode()
        
        // If color bubble is shown, hide it in camera mode to switch to filter mode
        // Need to reload collection view because the color collection view setting is different from filter
        if isBubbleCollectionViewShown && currentMode.isMode(mode: .Draw) || currentMode.isMode(mode: .Text) {
            toggleFilterMode()
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
        
        let newImgID = Image.save(image: imageData)
        let postID = Post.create(assetID: newImgID, assetType: .image)
        Matchup.submitPost(postID)
        print("Upload completed")
        self.removeAllItems()
        busy.stopAnimating()
        busy.removeFromSuperview()
        self.toggleCameraMode()
        
    }
    @IBAction func onHashtagField(_ sender: UITextField) {
        currentMode.toggle(mode: .Hashtag)
    }
    
    internal func toggleSwipeGestureRecognizer(mode: Mode) {
        guard let swipeLeftRecognizer = swipeLeftRecognizer, let swipeRightRecognizer = swipeRightRecognizer else {
            print("swipe recognizer is nil")
            return
        }
        
        var isEnabled = false
        switch mode {
        case .Camera:
            isEnabled = false
        case .Edit:
            isEnabled = true
        case .Filter:
            isEnabled = true
        case .Draw:
            isEnabled = false
        case .Text:
            isEnabled = false
        case .Font:
            isEnabled = false
        case .Hashtag:
            print("Something is wrong. toggleSwipeGestureRecognizer is fired under Hashtag mode.")
        }
        
        swipeRightRecognizer.isEnabled = isEnabled
        swipeLeftRecognizer.isEnabled = isEnabled
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
        if currentMode.isMode(mode: .Camera) {
            
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
        if currentMode.isMode(mode: .Camera) {
            
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
                self.toggleEditMode()
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
        var startConstraint: CGFloat = Constraint.FilterNameLabel.Outside.Left
        var endConstraint: CGFloat = Constraint.FilterNameLabel.Outside.Right
        
        // If swipe animation comes from the right side and goes to the left side
        if direction == UISwipeGestureRecognizerDirection.left {
            startConstraint = Constraint.FilterNameLabel.Outside.Right
            endConstraint = Constraint.FilterNameLabel.Outside.Left
        }
        
        // Set starting position
        filterNameLabelCenterConstraint.constant = startConstraint
        view.layoutIfNeeded()
        
        // Label first moves to the center and wait for delay time.
        UIView.animate(withDuration: Animation.FilterNameLabelDuration, delay: 0, options: [], animations: {
            self.filterNameLabel.text = name
            self.filterNameLabelCenterConstraint.constant = Constraint.FilterNameLabel.Inside.Center
            self.view.layoutIfNeeded()
        }) { (completed: Bool) in
            // Label moves out of screen
            
            UIView.animate(withDuration: Animation.FilterNameLabelDuration, delay: Animation.FilterNameLabelDelay, options: [], animations: {
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
    internal func toggleCameraMode() {
        removeAllItems()
        currentMode.toggle(mode: .Camera)
        hideEditSubviews()
        toggleSwipeGestureRecognizer(mode: .Camera)
        toggleBubbleCollectionView()
        delegate?.showAllTabs()
        
        stillCamera?.startCapture()
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.editButtonBottomConstraint.constant = Constraint.Button.Edit.Bottom.Hide
            self.view.layoutIfNeeded()
            
        }) { (completed: Bool) in
        }
        // Show tabs
    }
    
    /** Shows picture taken to edit. */
    internal func toggleEditMode() {
        currentMode.toggle(mode: .Edit)
        toggleSwipeGestureRecognizer(mode: .Edit)
        showEditSubviews()
        
        delegate?.hideAllTabs()
        stillCamera?.stopCapture()
        
        // Show cancel button and upload button
        // Hide tabs
        UIView.animate(withDuration: 0.2, animations: {
            if self.isBubbleCollectionViewShown {
                self.editButtonBottomConstraint.constant = Constraint.Button.Edit.Bottom.ShowWithCollectionView
            } else {
                self.editButtonBottomConstraint.constant = Constraint.Button.Edit.Bottom.Show
            }
            self.view.layoutIfNeeded()
        }) { (completed: Bool) in
            
        }
        toggleFilterMode()
    }
    
    /** Turn on filter mode with bubble. isFilterMode is always on unless draw or text mode is on. */
    internal func toggleFilterMode() {
        
        if currentMode.isMode(mode: .Filter) {
            toggleBubbleCollectionView()
        } else {
            // Switched to another mode
            currentMode.toggle(mode: .Filter)
            if !isBubbleCollectionViewShown {
                bubbleCollectionView.reloadData()
                toggleBubbleCollectionView()
            } else {
                bubbleCollectionView.reloadData()
            }
        }

        toggleUserInteraction(mode: currentMode)
        sortSubviews(mode: currentMode)
        toggleSwipeGestureRecognizer(mode: .Filter)
        currentMode.toggle(mode: .Filter)
        print("isBubbleCollectionViewShown: \(isBubbleCollectionViewShown)")
    }
    
    /** Enables drawing mode with bubble. */
    internal func toggleDrawMode() {
        if currentMode.isMode(mode: .Draw) {
            toggleBubbleCollectionView()
        } else {
            // Switched to another mode
            currentMode.toggle(mode: .Draw)
            if !isBubbleCollectionViewShown {
                bubbleCollectionView.reloadData()
                toggleBubbleCollectionView()
            } else {
                bubbleCollectionView.reloadData()
            }
        }
        
        currentMode.toggle(mode: .Draw)
        toggleUserInteraction(mode: currentMode)
        sortSubviews(mode: currentMode)
        toggleSwipeGestureRecognizer(mode: .Draw)
        print("isBubbleCollectionViewShown: \(isBubbleCollectionViewShown)")

    }
    
    /** Enables text mode with bubble. */
    internal func toggleTextMode() {
        // animation is implemented in keyboardWillShow and hide
        currentMode.toggle(mode: .Text)
        toggleUserInteraction(mode: currentMode)
        sortSubviews(mode: currentMode)
        toggleSwipeGestureRecognizer(mode: .Text)
    }
    
    // TODO: Figure out how font mode works. works with text mode?
    internal func fontMode() {
        currentMode.toggle(mode: .Font)
    }
    
    /** Shows collection view bubble. */
    internal func toggleBubbleCollectionView() {
        // Filter editing
        
        if !isBubbleCollectionViewShown {
            isBubbleCollectionViewShown = !isBubbleCollectionViewShown
            
            // Show animation
            UIView.animate(withDuration: Animation.BubbleCollectionViewShowDuration, animations: {
                // Move down for the height of collection view to show it
                self.bubbleCollectionViewTopConstraint.constant = Constraint.BubbleCollectionView.Top.Show
                
                // Move down the filter button
                self.editButtonBottomConstraint.constant = Constraint.Button.Filter.Bottom.ShowWithCollectionView
                
                if !self.currentMode.isMode(mode: .Camera) {
                    // Move down the edit buttons
                    self.editButtonBottomConstraint.constant = Constraint.Button.Edit.Bottom.ShowWithCollectionView
                }
                
                self.view.layoutIfNeeded()
            })
        } else {
            
            isBubbleCollectionViewShown = !isBubbleCollectionViewShown
            // Hide animation
            UIView.animate(withDuration: Animation.BubbleCollectionViewShowDuration, animations: {
                // Move up fot the height of collection view to hide it under camera
                self.bubbleCollectionViewTopConstraint.constant = Constraint.BubbleCollectionView.Top.Hide
                
                // Move up the filter button
                self.editButtonBottomConstraint.constant = Constraint.Button.Filter.Bottom.Show
                
                if !self.currentMode.isMode(mode: .Camera) {
                    // Move up the edit buttons
                    self.editButtonBottomConstraint.constant = Constraint.Button.Edit.Bottom.ShowWithCollectionView
                }
                
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    func showEditSubviews() {
        cancelButton.isHidden = false
        uploadButton.isHidden = false
        photoImageView.isHidden = false
        drawImageView.isHidden = false
        textImageView.isHidden = false
        filterNameLabel.isHidden = false
        hashtagTextField.isHidden = false
    }
    
    func hideEditSubviews() {
        cancelButton.isHidden = true
        uploadButton.isHidden = true
        photoImageView.isHidden = true
        drawImageView.isHidden = true
        textImageView.isHidden = true
        filterNameLabel.isHidden = true
        hashtagTextField.isHidden = true
    }
    
    /** Sort view's subview. */
    func sortSubviews(mode: Mode) {
        switch mode {
        case .Edit:
            view.bringSubview(toFront: photoImageView)
            view.bringSubview(toFront: cancelButton)
            view.bringSubview(toFront: uploadButton)
            view.bringSubview(toFront: hashtagTextField)
            view.bringSubview(toFront: filterNameLabel)
        case .Filter:
            view.bringSubview(toFront: photoImageView)
            view.bringSubview(toFront: textImageView)
            view.bringSubview(toFront: drawImageView)
            view.bringSubview(toFront: cancelButton)
            view.bringSubview(toFront: uploadButton)
            view.bringSubview(toFront: hashtagTextField)
            view.bringSubview(toFront: filterNameLabel)
        case .Draw:
            view.bringSubview(toFront: photoImageView)
            view.bringSubview(toFront: textImageView)
            view.bringSubview(toFront: drawImageView)
            view.bringSubview(toFront: cancelButton)
            view.bringSubview(toFront: uploadButton)
            view.bringSubview(toFront: hashtagTextField)
        case .Text:
            view.bringSubview(toFront: textImageView)
            view.bringSubview(toFront: bubbleCollectionView)
            view.bringSubview(toFront: cancelButton)
            view.bringSubview(toFront: uploadButton)
            view.bringSubview(toFront: hashtagTextField)
        default:
            print("in default in sortSubviews")
        }
    }
    
    /** Hides views not needed. */
    func toggleUserInteraction(mode: Mode) {
        switch mode {
        case .Filter:
            textImageView.isUserInteractionEnabled = false
            drawImageView.isUserInteractionEnabled = false
            photoImageView.isUserInteractionEnabled = true
            
        case .Draw:
            textImageView.isUserInteractionEnabled = false
            drawImageView.isUserInteractionEnabled = true
            photoImageView.isUserInteractionEnabled = false

        case .Text:
            textImageView.isUserInteractionEnabled = true
            drawImageView.isUserInteractionEnabled = false
            photoImageView.isUserInteractionEnabled = false
        default:
            print("In default in toggleUserInteraction")
        }
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
        if currentMode.isMode(mode: .Filter) {
            count = filters.count
        } else if currentMode.isMode(mode: .Draw) || currentMode.isMode(mode: .Text) {
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
        
        if currentMode.isMode(mode: .Filter) {
            let filter = filters[indexPath.item]
            cell.nameLabel.text = filter.name
            cell.nameLabel.textColor = UIColor.black
            
            // Set image
            let image = UIImage(named: filter.imageUrlString)
            cell.contentImageView.image = image
        } else if currentMode.isMode(mode: .Draw)  || currentMode.isMode(mode: .Text) {
            let color = colors[indexPath.item]
            cell.contentImageView.backgroundColor = color.uiColor
            //cell.backgroundColor = color.uiColor
            cell.nameLabel.text = color.name
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentMode.isMode(mode: .Filter) {
            
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
            
        } else if currentMode.isMode(mode: .Draw) || currentMode.isMode(mode: .Text) {
            
            colorIndex.current = indexPath.item
            currentColor = colors[colorIndex.current].uiColor
            if isEditing {
                if let currentTextField = currentTextField {
                    currentTextField.textColor = currentColor
                }
            }
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
        self.currentTextField = textField
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
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == hashtagTextField {
            currentMode.toggle(mode: .Hashtag)
        } else if textField == currentTextField {
            currentMode.toggle(mode: .Text)
        }
        return true
    }
    
    /** On change resize the view */
    @objc private func textFieldDidChange(_ sender: UITextField) {
        sender.sizeToFit()
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func addKeyboardObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if currentMode.isMode(mode: .Text) {
            print("Keyboard will show")
            let info  = notification.userInfo!
            guard let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                print("Can't convert info[UIKeyboardFrameEndUserInfoKey] to CGRect")
                return
            }
            
            Constraint.BubbleCollectionView.Top.ShowWithKeyboard = UIScreen.main.bounds.height - keyboardFrame.height - bubbleCollectionView.frame.height
            print("keyboard frame: \(keyboardFrame)")
            print("Constraint.BubbleCollectionView.Top.ShowWithKeyboard: \(Constraint.BubbleCollectionView.Top.ShowWithKeyboard)")
            toggleTextMode()
            isBubbleCollectionViewShown = false
            bubbleCollectionView.reloadData()
            toggleBubbleCollectionView()
            UIView.animate(withDuration: 0.1) {
                self.view.bringSubview(toFront: self.textImageView)
                self.view.bringSubview(toFront: self.bubbleCollectionView)
                self.bubbleCollectionViewTopConstraint.constant = Constraint.BubbleCollectionView.Top.ShowWithKeyboard
                print("self.bubbleCollectionViewTopConstraint.constant: \(self.bubbleCollectionViewTopConstraint.constant)")
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("Keyboard will hide")
        if currentMode.isMode(mode: .Text) {
            UIView.animate(withDuration: 0.1) {
                self.view.bringSubview(toFront: self.textImageView)
                self.view.bringSubview(toFront: self.bubbleCollectionView)
                self.bubbleCollectionViewTopConstraint.constant = Constraint.BubbleCollectionView.Top.Show
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: Drawing
extension CameraViewController {
    
    /**
     Called when you are about to touch the screen.
     Stores the point you have touched to use it as the starting point of a line.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentMode.isMode(mode: .Draw) {
            if let touch = touches.first {
                lastPoint = touch.location(in: view)
            }
        }
    }
    
    /**
     Draw a line from a point to another point on an image view. This method is called everytime touchesMoved is called
     */
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        if currentMode.isMode(mode: .Draw) {
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
        if currentMode.isMode(mode: .Draw) {
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
