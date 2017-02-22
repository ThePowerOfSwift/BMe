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

class CameraViewController: UIViewController, SatoCameraDatasource, BubbleMenuCollectionViewControllerDatasource, BubbleMenuCollectionViewControllerDelegate {
    
    /** Model */
    let satoCamera = SatoCamera()

    // MARK: Master views
    // Must always be behind all other views
    @IBOutlet var sampleBufferView: UIView!
    // Must always be on top of sampleBuffer
    @IBOutlet var outputView: UIView!
    /** 
     View that holds all control views and the active effect tool; always floating.
     When an effect is active, it is moved to be the bottom backing view of controlView (under control containers)
     */
    @IBOutlet var controlView: UIView!

    // MARK: Image Effects
    /** Tracks which effect tool is currently selected in effects: [UIView] */
    var lastSelectedEffect = -1
    var selectedEffect = -1 {
        didSet {
            didSelectEffect()
        }
    }
    /** All the effects to be loaded */
    var effects: [AnyObject] = [FilterImageEffect(),DrawImageEffectView()]
    
    // MARK: Camera Controls & Tools
    // Tools
    /** Container view for effect tools */
    @IBOutlet var effectToolView: UIView!
    /** Container view for effect options */
    @IBOutlet var effectOptionView: UIView!
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
        
        // Finalize setup
        view.bringSubview(toFront: controlView)
        // Must manually select first effect
        selectFirstEffect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setups
    
    func setupSatoCamera() {
        satoCamera.datasource = self
    }
    
    func setupEffects() {
        // Add each effect
        for effect in effects {
            if let effect = effect as? UIView {
                effect.frame = view.bounds
                effect.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                view.addSubview(effect)
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
    
    func didSelectEffect() {
        // Move selected effect view to fore
        // Remove last effect from control view
        if lastSelectedEffect >= 0, let effect = effects[lastSelectedEffect] as? UIView {
            view.insertSubview(effect, belowSubview: controlView)
        }
        // Bring selected effect view to back of control view
        if let effect = effects[selectedEffect] as? UIView {
            controlView.insertSubview(effect, at: 0)
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
            // If it's the same selection, do nothing
            if selectedEffect != indexPath.row {
                lastSelectedEffect = selectedEffect
                selectedEffect = indexPath.row
            }
        }
        // Selection made on tool options menu
        else if (bubbleMenuCollectionViewController == effectOptionBubbleCVC) {
            if let effect = effects[selectedEffect] as? CameraViewBubbleMenu {
                effect.menu(bubbleMenuCollectionViewController, didSelectItemAt: indexPath)
            }
        }
    }
}

protocol CameraViewBubbleMenu {
    /** Contents of the bubble menu */
    var menuContent: [BubbleMenuCollectionViewCellContent] { get }
    /** The icon image of the datasource */
    var iconContent: BubbleMenuCollectionViewCellContent { get }
    
    func menu(_ sender: BubbleMenuCollectionViewController, didSelectItemAt indexPath: IndexPath)
    func didSelect(_ sender: BubbleMenuCollectionViewController)
}
