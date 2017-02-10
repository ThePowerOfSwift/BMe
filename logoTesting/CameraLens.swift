//
//  CameraLens.swift
//  logoTesting
//
//  Created by parry on 2/9/17.
//  Copyright © 2017 parry. All rights reserved.
//

import UIKit

@IBDesignable
class StopwatchHand: UIView {
    override func drawRect(rect: CGRect) {
        Camera.drawStopwatch_Hand()
    }
}
