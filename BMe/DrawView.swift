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

    /** Tracks the user's last touch point; used to draw lines between touch points */
    private var currentPoint = CGPoint.zero
    private var lastPoint = CGPoint.zero
    private var lastlastPoint = CGPoint.zero

    /** The drawn line's width setting */
    var lineWidth: CGFloat = 7.0
    /** The drawn line's color setting */
    var currentColor: UIColor = UIColor.black
    
    var path: CGMutablePath = CGMutablePath()
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        // Setup image view where draw actions are drawn
        backgroundColor = UIColor.clear
    
    }

    func reset() {
        setup()
    }
    
    // MARK: Draw methods
    
    override func draw(_ rect: CGRect) {
    // clear rect
//    [self.backgroundColor set];
//    UIRectFill(rect);
    
    // get the graphics context and draw the path
        if let context = UIGraphicsGetCurrentContext() {
            context.addPath(path)
            context.setLineCap(.round)
            context.setLineWidth(lineWidth)
            context.setStrokeColor(currentColor.cgColor)

            context.strokePath()
        }
    }
    
    /** Starts a sequence of touches by the user */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Initializes our point records to current location
            lastPoint = touch.previousLocation(in: self)
            lastlastPoint = touch.previousLocation(in: self)
            currentPoint = touch.previousLocation(in: self)
            
            // call touchesMoved:withEvent:, to possibly draw on zero movement
            touchesMoved(touches, with: event)
        }
    }
    
    /** Tracks user touches on the screen (like a drag) and draws a line between every two points */
    let minDistance: CGFloat = 0
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            
            let dx = point.x - currentPoint.x
            let dy = point.y - currentPoint.y
            
            if (dx * dx + dy * dy) < minDistance {
                return
            }
            
            // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
            lastlastPoint = lastPoint
            lastPoint = touch.previousLocation(in: self)
            currentPoint = touch.location(in: self)
            
            let mid1: CGPoint = midPoint(p1: lastPoint, p2: lastlastPoint);
            let mid2: CGPoint = midPoint(p1: currentPoint, p2: lastPoint);
            
            // to represent the finger movement, create a new path segment,
            // a quadratic bezier path from mid1 to mid2, using previous as a control point
            let subpath = CGMutablePath()
            subpath.move(to: CGPoint(x: mid1.x, y: mid1.y))
            subpath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: lastPoint.x, y: lastPoint.y))
            
            // compute the rect containing the new segment plus padding for drawn line
            let bounds = subpath.boundingBoxOfPath
            let drawBox = bounds.insetBy(dx: -2.0 * lineWidth, dy: -2.0 * lineWidth)
            
            // append the quad curve to the accumulated path so far.
            path.addPath(subpath)

            setNeedsDisplay(drawBox)
        }
    }
    
    private func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        let point = CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
        return point
    }

    
    /** Draw a line from one point to another on an image view */
    private func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        // Start a context with the size of vc view
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, imageScale)
        if let context = UIGraphicsGetCurrentContext() {
            // Draw previous contents (preserve)
//            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.size.height))

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
//            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }
}
