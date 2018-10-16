

//
//  XHDrawboard.swift
//  WeChat
//
//  Created by Li on 2018/9/22.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

/// Subclass should not override touch methods.
 class XHDrawboard: UIView {
    
    weak var delegate: XHDrawboardDelegate?
    
    private var currentImage: UIImage? {
        willSet {
            if drawUndoManager.isUndoing {
                path = nil
            } else {
                drawUndoManager.registerUndo(withTarget: self, selector: #selector(undoDraw(_:)), object: currentImage)
            }
        }
    }
    
    /// default is black(333333),only effect lineBrush.
    var lineColor: UIColor = UIColor.red
    
    private var lineWidth: CGFloat {
        return 5 / scale
    }
    
    var scale: CGFloat = 1
    
    private lazy var drawUndoManager = UndoManager()
    
    var canUndo: Bool {
        return drawUndoManager.canUndo
    }
    
    func undo() {
        drawUndoManager.undo()
    }
    
    @objc private func undoDraw(_ image: UIImage?) {
        currentImage = image
        setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var path: XHBezierPath!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        delegate?.drawboardDidBeginDrawing(self)
        let point = touch.location(in: self)
        path = XHBezierPath(lineColor: lineColor)
        path.lineWidth = lineWidth
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
        drawLine(touch)
        currentImage = snapImage()
        delegate?.drawboardDidEndDrawing(self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        drawLine(touch)
        currentImage = snapImage()
        delegate?.drawboardDidEndDrawing(self)
    }
    
    private func drawLine(_ touch: UITouch) {
        let point = touch.location(in: self)
        let previousPoint = touch.previousLocation(in: self)
        let previousEnd = path.currentPoint
        path.addQuadCurve(to: point, controlPoint: previousPoint)
        /// 设置重绘区域要完全包含所绘的线
        let minX = min(point.x, min(previousPoint.x, previousEnd.x))
        let minY = min(point.y, min(previousPoint.y, previousEnd.y))
        let maxX = max(point.x, min(previousPoint.x, previousEnd.x))
        let maxY = max(point.y, min(previousPoint.y, previousEnd.y))
        let x = minX - lineWidth / 2 - 1
        let y = minY - lineWidth / 2 - 1
        let width = maxX - minX + lineWidth
        let height = maxY - minY + lineWidth
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
        }
    }
    
    fileprivate class XHBezierPath: UIBezierPath {
        
        var lineColor: UIColor
        
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


protocol XHDrawboardDelegate: NSObjectProtocol {
    
    func drawboardDidBeginDrawing(_ drawboard: XHDrawboard)
    
    func drawboardDidEndDrawing(_ drawboard: XHDrawboard)
    
}

extension UIView {
    
    func snapImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
