//  Filter.swift
//
//  Created by Satoru Sasozaki on 1/29/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit

class Filter: NSObject {
    var name: String
    var filter: CIFilter
    var imageUrlString: String

    init(name: String, filter: CIFilter, imageUrlString: String) {
        self.name = name
        self.filter = filter
        self.imageUrlString = imageUrlString
    }

    func generateFilteredCIImage(sourceImage: CIImage) -> CIImage? {
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }

    class func list() -> [Filter] {
        // Double size for testing
        return [Filter(name: "Sepia", filter: CIFilter(name: "CISepiaTone")!, imageUrlString: "alcatraz.jpg"),
                Filter(name: "False", filter: CIFilter(name: "CIFalseColor")!, imageUrlString: "chinatown.jpg"),
                Filter(name: "Sepia", filter: CIFilter(name: "CISepiaTone")!, imageUrlString: "alcatraz.jpg"),
                Filter(name: "False", filter: CIFilter(name: "CIFalseColor")!, imageUrlString: "chinatown.jpg"),
                Filter(name: "Sepia", filter: CIFilter(name: "CISepiaTone")!, imageUrlString: "alcatraz.jpg"),
                Filter(name: "False", filter: CIFilter(name: "CIFalseColor")!, imageUrlString: "chinatown.jpg"),
                Filter(name: "Sepia", filter: CIFilter(name: "CISepiaTone")!, imageUrlString: "alcatraz.jpg"),
                Filter(name: "False", filter: CIFilter(name: "CIFalseColor")!, imageUrlString: "chinatown.jpg")
        ]
    }
}

