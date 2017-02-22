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

    // MARK: SatoCamerDatasource
    @IBOutlet var sampleBufferView: UIView!
    @IBOutlet var outputView: UIView!
    
    // MARK: ImageEffects
    var drawEffect = DrawImageEffectView()
    
    // MARK: ImageEffect view containers
    @IBOutlet var effectBubbleMenuView: UIView!
    @IBOutlet var effectButton: UIView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSatoCamera()
        setupDrawEffect()
        setupBubbleMenu()
        
        view.bringSubview(toFront: effectBubbleMenuView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setups
    
    func setupSatoCamera() {
        satoCamera.datasource = self
    }
    
    func setupDrawEffect() {
        drawEffect.frame = view.bounds
        drawEffect.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(drawEffect)
    }
    
    func setupBubbleMenu() {
        // Give menu transparent backing
        effectBubbleMenuView.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: 77, height: 77)
        
        let bubbleCVC = BubbleMenuCollectionViewController(collectionViewLayout: layout)
        bubbleCVC.datasource = self
        bubbleCVC.delegate = self
        
        addChildViewController(bubbleCVC)
        effectBubbleMenuView.addSubview(bubbleCVC.view)
        bubbleCVC.view.frame = effectBubbleMenuView.bounds
        bubbleCVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bubbleCVC.didMove(toParentViewController: self)
    }
    
    // MARK: BubbleMenuCollectionViewControllerDatasource
    
    func bubbleMenuContent(for sender: BubbleMenuCollectionViewController) -> [BubbleMenuCollectionViewCellContent] {
        return drawEffect.bubbleMenuContent
    }
    
    // MARK: BubbleMenuCollectionViewControllerDelegate

    func bubbleMenuCollectionViewController(_ bubbleMenuCollectionViewController: BubbleMenuCollectionViewController, didSelectItemAt indexPath: IndexPath) {
        drawEffect.bubbleMenu(bubbleMenuCollectionViewController, didSelectItemAt: indexPath)
    }
}

protocol CameraViewBubbleMenu {
    /** Contents of the bubble menu */
    var bubbleMenuContent: [BubbleMenuCollectionViewCellContent] { get }
    /** The icon image of the datasource */
    var buttonView: UIButton { get }
    
    func bubbleMenu(_ sender: BubbleMenuCollectionViewController, didSelectItemAt indexPath: IndexPath)
}
