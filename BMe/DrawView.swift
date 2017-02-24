//
//  DrawView.swift
//  effects
//
//  Created by Jonathan Cheng on 2/20/17.
//  Copyright © 2017 Jonathan Cheng. All rights reserved.
//

import UIKit

/** CGContext; Quality; 0.0 is screen resolution */
private let imageScale: CGFloat = 0.00

/** Draws a line to view following user touches */
class DrawView: UIView {

    /** The view that holds and draws the line */
    private var imageView = UIImageView()
    /** Tracks the user's last touch point; used to draw lines between touch points */
    private var lastPoint = CGPoint.zero
    
    /** The drawn line's width setting */
    var lineWidth: CGFloat = 7.0
    /** The drawn line's color setting */
    var currentColor: UIColor = UIColor.black
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // Setup image view where draw actions are drawn
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
    }

    
    // MARK: Draw methods
    
    /** Starts a sequence of touches by the user */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
        }
    }
    
    /** Tracks user touches on the screen (like a drag) and draws a line between every two points */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Get the current touch
            let currentPoint = touch.location(in: self)
            
            // Draw a line between last point and current point
            drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            
            // Assign the current point to last point
            lastPoint = currentPoint
        }
    }
    
    /** Draw a line from one point to another on an image view */
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        // Start a context with the size of vc view
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, imageScale)
        if let context = UIGraphicsGetCurrentContext() {
            // Draw previous contents (preserve)
            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.size.height))

            // Add a line segment from lastPoint to currentPoint.
            context.move(to: fromPoint)
            context.addLine(to: toPoint)
            
            // Setup draw settings
            context.setLineCap(CGLineCap.round)
            context.setLineWidth(lineWidth)
            context.setStrokeColor(currentColor.cgColor)
            context.setBlendMode(CGBlendMode.normal)
            
            // Draw the path
            context.strokePath()
            
            // Apply the path to drawingImageView
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
}
