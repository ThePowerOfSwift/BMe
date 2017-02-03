//
//  Filter.swift
//  GPUImageObjcDemo
//
//  Created by Satoru Sasozaki on 1/29/17.
//  Copyright © 2017 Satoru Sasozaki. All rights reserved.
//

import UIKit
import GPUImage

class Filter: NSObject {
    var name: String
    var filter: GPUImageOutput
    var imageUrlString: String
    var cachedFilteredImage: UIImage?
    
    init(name: String, filter: GPUImageOutput, imageUrlString: String) {
        self.name = name
        self.filter = filter
        self.imageUrlString = imageUrlString
    }
    
    class func list() -> [Filter] {

        // Double size for testing
        return [Filter(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg"),
                Filter(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg"),
                Filter(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg"),
                Filter(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg")]
    }
    
    func setFilteredImage(image: UIImage?) {
        if let image = image {
            cachedFilteredImage = image
        } else {
            cachedFilteredImage = nil
        }
    }
}
