

//
//  XHDrawboard.swift
//  WeChat
//
//  Created by Li on 2018/9/22.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

/// Subclass should not override touch methods.
/// CurrentImage property can be used for K-V-C to observer one line drawing.
 class XHDrawboard: UIView {
    
    /// default is black(333333)
    var currentLineColor: UIColor = UIColor.black
    
    var currentLineWidth: CGFloat = 5
    
    var canUndo: Bool {
        return undoManager?.canUndo ?? false
    }
    
    var canRedo: Bool {
        return undoManager?.canRedo ?? false
    }
    
    weak var delegate: XHDrawboardDelegate?
    
    func undo() {
        guard let undoManager = self.undoManager,undoManager.canUndo else { return }
        undoManager.undo()
    }
    
    func redo() {
        guard let undoManager = self.undoManager,undoManager.canRedo else { return }
        undoManager.redo()
    }
    
    private func snapImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// readonly,Key-Value-Coding is available
    @objc private(set) var currentImage: UIImage? {
        willSet {
            willChangeValue(for: \XHDrawboard.currentImage)
            if let undoManager = self.undoManager {
                if !undoManager.isUndoing {
                    undoManager.registerUndo(withTarget: self, selector: #selector(undoDraw(_:)), object: currentImage)
                } else {
                    (undoManager.prepare(withInvocationTarget: self) as AnyObject).undoDraw(currentImage)
                }
            }
        }
        didSet {
            didChangeValue(for: \XHDrawboard.currentImage)
        }
    }
    
    
    
    @objc private func undoDraw(_ image: UIImage?) {
        currentImage = image
        setNeedsDisplay()
    }
    
    init(content: UIImage?) {
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        if let content = content {
            layer.contents = content.cgImage
            currentImage = content
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        if let image = currentImage {
            return image.size
        }
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    private var path: XHBezierPath!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        delegate?.drawboardDidBeginDrawing?(self)
        undoManager?.beginUndoGrouping()
        let point = touch.location(in: self)
        path = XHBezierPath(lineColor: currentLineColor)
        path.lineWidth = currentLineWidth
        path.move(to: point)
    }
    
    private func middlePointBetween(_ point1: CGPoint,point2: CGPoint) -> CGPoint {
        return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        drawLine(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        drawLine(touch,isCompleted: true)
        currentImage = snapImage()
        undoManager?.endUndoGrouping()
        delegate?.drawboardDidEndDrawing?(self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        drawLine(touch,isCompleted: true)
        currentImage = snapImage()
        undoManager?.endUndoGrouping()
        delegate?.drawboardDidEndDrawing?(self)
    }
    
    private func drawLine(_ touch: UITouch,isCompleted: Bool = false) {
        let point = touch.location(in: self)
        let previousPoint = touch.previousLocation(in: self)
        let previousEnd = path.currentPoint
        path.addQuadCurve(to: point, controlPoint: previousPoint)
        /// 设置重绘区域要完全包含所绘的线
        let minX = min(point.x, min(previousPoint.x, previousEnd.x))
        let minY = min(point.y, min(previousPoint.y, previousEnd.y))
        let maxX = max(point.x, min(previousPoint.x, previousEnd.x))
        let maxY = max(point.y, min(previousPoint.y, previousEnd.y))
        let x = minX - currentLineWidth / 2 - 1
        let y = minY - currentLineWidth / 2 - 1
        let width = maxX - minX + currentLineWidth
        let height = maxY - minY + currentLineWidth
        path.isCompleted = isCompleted
        setNeedsDisplay(CGRect(x: x, y: y, width: width, height: height))
    }
    
    override func draw(_ rect: CGRect) {
        if let currentImage = self.currentImage {
            currentImage.draw(in: bounds)
        }
        if let path = self.path {
            path.lineColor.setStroke()
            let context = UIGraphicsGetCurrentContext()
            context?.setBlendMode(.normal)
            path.stroke()
            if path.isCompleted {
                self.path = nil
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    fileprivate class XHBezierPath: UIBezierPath {
        
        var lineColor: UIColor
        
        var isCompleted: Bool = false
        
        init(lineColor: UIColor) {
            self.lineColor = lineColor
            super.init()
            lineCapStyle = .round
            lineJoinStyle = .round
            flatness = 1//提高性能，值越小越消耗性能，默认为0.6
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}


@objc protocol XHDrawboardDelegate: NSObjectProtocol {
    
    @objc optional func drawboardDidBeginDrawing(_ drawboard: XHDrawboard)
    
    @objc optional func drawboardDidEndDrawing(_ drawboard: XHDrawboard)
    
}
