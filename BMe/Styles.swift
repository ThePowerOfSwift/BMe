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
        static let Tertiary = UIColor(red: RGB.Tertiary.R, green: RGB.Tertiary.G, blue: RGB.Tertiary.B, alpha: 1.0)
        struct RGB {
            struct Primary { // blue 76A4A4
                static let R: CGFloat = 34.0 / 255.0
                static let G: CGFloat = 116 / 255.0
                static let B: CGFloat = 219 / 255.0
            }
            struct Secondary { // gray 605860
                static let R: CGFloat = 96 / 255.0
                static let G: CGFloat = 88 / 255.0
                static let B: CGFloat = 96 / 255.0
            }
            struct Tertiary { // yellow FFD608
                static let R: CGFloat = 255 / 255.0
                static let G: CGFloat = 214 / 255.0
                static let B: CGFloat = 8 / 255.0
            }
        }
    }
    struct Avatar {
        static let borderWidth: CGFloat = 1.5
        static let borderColor = Color.Primary
    }
    struct Logo {
        static let size = CGSize(width: 100, height: 100)
    }
    struct BusyIndicator {
        static let size = Logo.size
        static let duration: TimeInterval = 1.00
    }
    struct Shapes {
        static let cornerRadius: CGFloat = 20.0
    }
}
