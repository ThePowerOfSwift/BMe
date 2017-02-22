//
//  FilterImageEffect.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/22/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

class FilterImageEffect: NSObject, CameraViewBubbleMenu {

    var bubbleMenuContent: [BubbleMenuCollectionViewCellContent] = []
    var iconBubbleContent = BubbleMenuCollectionViewCellContent(image: UIImage(named: "golden_gate_bridge.jpg")!, label: "Filter")
    var delegate: FilterImageEffectDelegate?
    
    override init() {
        super.init()
        
        setupBubbleMenuContent()
    }
    
    func setupBubbleMenuContent() {
        for filter in Filter.list() {
            let bubble = BubbleMenuCollectionViewCellContent(image: UIImage(named:filter.imageUrlString)!, label: filter.name)
            bubbleMenuContent.append(bubble)
        }
    }
    
    // MARK: CameraViewBubbleMenu
    
    func bubbleMenu(_ sender: BubbleMenuCollectionViewController, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectFilter(self, indexPath: indexPath)
    }

}

protocol FilterImageEffectDelegate {
    func didSelectFilter(_ sender: FilterImageEffect, indexPath: IndexPath)
}
