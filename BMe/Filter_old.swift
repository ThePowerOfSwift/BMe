//
//  Filter_old.swift
//  BMe
//
//  Created by Jonathan Cheng on 2/22/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

import GPUImage

class Filter_old: NSObject {
    var name: String
    var filter: GPUImageOutput
    var imageUrlString: String
    var cachedFilteredImage: UIImage?
    
    init(name: String, filter: GPUImageOutput, imageUrlString: String) {
        self.name = name
        self.filter = filter
        self.imageUrlString = imageUrlString
    }
    
    class func list() -> [Filter_old] {
        
        // Double size for testing
        return [Filter_old(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter_old(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter_old(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter_old(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg"),
                Filter_old(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter_old(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter_old(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter_old(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg"),
                Filter_old(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter_old(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter_old(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter_old(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg"),
                Filter_old(name: "Plain", filter: GPUImageFilter(), imageUrlString: "alcatraz.jpg"),
                Filter_old(name: "Amatorka", filter: GPUImageAmatorkaFilter(), imageUrlString: "chinatown.jpg"),
                Filter_old(name: "Soft", filter: GPUImageSoftEleganceFilter(), imageUrlString: "golden_gate_bridge.jpg"),
                Filter_old(name: "Miss Etikate", filter: GPUImageMissEtikateFilter(), imageUrlString: "montgomery.jpg")]
    }
    
    func setFilteredImage(image: UIImage?) {
        if let image = image {
            cachedFilteredImage = image
        } else {
            cachedFilteredImage = nil
        }
    }
}
