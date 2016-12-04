//
//  Styles.swift
//  BMe
//
//  Created by Satoru Sasozaki on 12/1/16.
//  Copyright © 2016 Jonathan Cheng. All rights reserved.
//

import Foundation
import UIKit

struct Styles {
    struct Color {
        static let Primary = UIColor(red: RGB.Primary.R, green: RGB.Primary.G, blue: RGB.Primary.B, alpha: 1.0)
        static let Secondary = UIColor(red: RGB.Secondary.R, green: RGB.Secondary.G, blue: RGB.Secondary.B, alpha: 1.0)
        
        struct RGB {
            struct Primary {
                static let R: CGFloat = 118.0 / 255.0
                static let G: CGFloat = 164 / 255.0
                static let B: CGFloat = 164 / 255.0
            }
            struct Secondary {
                static let R: CGFloat = 96 / 255.0
                static let G: CGFloat = 88 / 255.0
                static let B: CGFloat = 96 / 255.0
            }
        }
    }
}
