//
//  Color.swift
//  GPUImageObjcDemo
//
//  Created by Satoru Sasozaki on 1/30/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit

class Color: NSObject {
    var name: String
    var uiColor: UIColor
    var cgColor: CGColor
    
    init(name: String, uiColor: UIColor, cgColor: CGColor) {
        self.name = name
        self.uiColor = uiColor
        self.cgColor = cgColor
    }
    
    /** Serves the list of colors. */
    class func list() -> [Color] {
        return [Color(name: "Red", uiColor: UIColor.red, cgColor: UIColor.red.cgColor),
                Color(name: "Blue", uiColor: UIColor.blue, cgColor: UIColor.blue.cgColor),
                Color(name: "Green", uiColor: UIColor.green, cgColor: UIColor.green.cgColor),
                Color(name: "Brown", uiColor: UIColor.brown, cgColor: UIColor.brown.cgColor),
                Color(name: "Cyan", uiColor: UIColor.cyan, cgColor: UIColor.cyan.cgColor),
                Color(name: "Magenta", uiColor: UIColor.magenta, cgColor: UIColor.magenta.cgColor),
                Color(name: "Purple", uiColor: UIColor.orange, cgColor: UIColor.orange.cgColor),
                Color(name: "Yellow", uiColor: UIColor.yellow, cgColor: UIColor.yellow.cgColor)]
    }
}
