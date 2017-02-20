//
//  ProgressBar.swift
//  Songy
//
//  Created by Main Account on 3/31/16.
//  Copyright © 2016 Ray Wenderlich. All rights reserved.
//
// Animating Progress Bar
// to use simply set the progress property which is a float



import UIKit

struct customColors {
    static let gradientColor = UIColor(red: 0.307, green: 0.630, blue: 0.557, alpha: 1.000)
    static let gradientColor2 = UIColor(red: 0.804, green: 0.804, blue: 1.000, alpha: 1.000)
    static let barColor = UIColor(red: 0.948, green: 1.000, blue: 0.707, alpha: 1.000)
}


class ProgressBar: UIView {

  fileprivate var innerProgress: CGFloat = 0.0
  var progress : CGFloat {
    set (newProgress) {
      if newProgress > bounds.width {
        innerProgress = bounds.width
      } else if newProgress < 0.0 {
        innerProgress = 0
      } else {
        innerProgress = newProgress
      }
        setNeedsDisplay()
    }
    get {
      return innerProgress
    }
  }

  override func draw(_ rect: CGRect) {
    PaintCode.drawProgressBar(frame: bounds,
      progress: progress)
  }

}


//MARK: PaintCode

public class PaintCode : NSObject {
    
    //// Cache
    
    private struct Cache {
        static let pinkColor: UIColor = UIColor(red: 0.431, green: 0.873, blue: 0.797, alpha: 1.000)
    }
    
    //// Colors
    
    public dynamic class var pinkColor: UIColor { return Cache.pinkColor }
    
    //// Drawing Methods
    
    public dynamic class func drawProgressBar(frame: CGRect = CGRect(x: 0, y: 0, width: 288, height: 13), progress: CGFloat = 94) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        //// Color Declarations
        let color3 = customColors.barColor
        let gradientColor = customColors.gradientColor
        let gradientColor2 = customColors.gradientColor2
        
        //// Gradient Declarations
        let gradient = CGGradient(colorsSpace: nil, colors: [gradientColor.cgColor, gradientColor.blended(withFraction: 0.5, of: gradientColor2).cgColor, gradientColor2.cgColor] as CFArray, locations: [0.15, 0.52, 0.94])!
        
        //// Progress Outline Drawing
        let progressOutlinePath = UIBezierPath(roundedRect: CGRect(x: frame.minX + 1, y: frame.minY + 1, width: fastFloor((frame.width - 1) * 1.00000 + 0.5), height: 10), cornerRadius: 5)
        color3.setFill()
        progressOutlinePath.fill()
        PaintCode.pinkColor.setStroke()
        progressOutlinePath.lineWidth = 1
        progressOutlinePath.stroke()
        
        
        //// Progress Active Drawing
        let progressActivePath = UIBezierPath(roundedRect: CGRect(x: 1, y: 1, width: progress, height: 10), cornerRadius: 5)
        context.saveGState()
        progressActivePath.addClip()
        let progressActiveRotatedPath = UIBezierPath()
        progressActiveRotatedPath.append(progressActivePath)
        var progressActiveTransform = CGAffineTransform(rotationAngle: 70 * -CGFloat.pi/180)
        progressActiveRotatedPath.apply(progressActiveTransform)
        let progressActiveBounds = progressActiveRotatedPath.cgPath.boundingBoxOfPath
        progressActiveTransform = progressActiveTransform.inverted()
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: progressActiveBounds.minX, y: progressActiveBounds.midY).applying(progressActiveTransform),
                                   end: CGPoint(x: progressActiveBounds.maxX, y: progressActiveBounds.midY).applying(progressActiveTransform),
                                   options: [])
        context.restoreGState()
    }
    
}

extension UIColor {
    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        var r1: CGFloat = 1, g1: CGFloat = 1, b1: CGFloat = 1, a1: CGFloat = 1
        var r2: CGFloat = 1, g2: CGFloat = 1, b2: CGFloat = 1, a2: CGFloat = 1
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: r1 * (1 - fraction) + r2 * fraction,
                       green: g1 * (1 - fraction) + g2 * fraction,
                       blue: b1 * (1 - fraction) + b2 * fraction,
                       alpha: a1 * (1 - fraction) + a2 * fraction);
    }
}
