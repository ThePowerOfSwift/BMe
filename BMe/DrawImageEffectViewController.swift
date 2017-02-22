//
//  DrawImageEffectViewController.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/20/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class DrawImageEffectViewController: UIViewController, ImageEffectMenuView, BubbleMenuCollectionViewControllerDatasource, BubbleMenuCollectionViewControllerDelegate {
    
    /** Model */
    var drawView = DrawView()
    
    // MARK: ImageEffectMenuView
    var buttonView = UIButton()
    var menuView: UIView? = UIView()

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setup() {
        setupDrawView()
        setupMenuView()
    }
    
    func setupDrawView() {
        drawView.frame = view.bounds
        drawView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(drawView)
    }
    
    func setupMenuView() {
        if let menuView = menuView {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            
            let bubbleCVC = BubbleMenuCollectionViewController(collectionViewLayout: layout)

            addChildViewController(bubbleCVC)
            menuView.addSubview(bubbleCVC.view)
            bubbleCVC.view.frame = menuView.bounds
            bubbleCVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bubbleCVC.didMove(toParentViewController: self)
            
            bubbleCVC.datasource = self
            bubbleCVC.delegate = self
        }
    }
    
    // MARK: BubbleMenuCollectionViewControllerDatasource
    
    func bubbles(_ sender: BubbleMenuCollectionViewController) -> [BubbleMenuCollectionViewCellContent] {
        var bubbles: [BubbleMenuCollectionViewCellContent] = []
        
        // Create color images and bubble contents for each color in list
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        for color in Color.list() {
            // Create an image with the color
            UIGraphicsBeginImageContext(rect.size)
            
            guard let context = UIGraphicsGetCurrentContext() else {
                print("Error: cannot get graphics context to create color image")
                UIGraphicsEndImageContext()
                break
            }
            context.setFillColor(color.cgColor)
            context.fill(rect)
            guard let colorImage = UIGraphicsGetImageFromCurrentImageContext() else {
                print("Error: cannot get color image from context")
                UIGraphicsEndImageContext()
                break
            }
            UIGraphicsEndImageContext()

            let bubble = BubbleMenuCollectionViewCellContent(image: colorImage, label: color.name)
            bubbles.append(bubble)
            
        }
        return bubbles
    }
    
    // MARK: BubbleMenuCollectionViewControllerDelegate
    
    func bubbleMenuCollectionViewController(_ bubbleMenuCollectionViewController: BubbleMenuCollectionViewController, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        
        drawView.currentColor = Color.list()[indexPath.row].uiColor
    }
    
}
