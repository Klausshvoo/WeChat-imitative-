//
//  XHMosaicView.swift
//  WeChat
//
//  Created by Li on 2018/10/15.
//  Copyright © 2018 Li. All rights reserved.
//

import UIKit

class XHMosaicView: UIView {
    
    var scale: CGFloat = 1
    
    weak var delegate: XHMosaicViewDelegate?

    private let imageView = UIImageView()
    
    init(content: UIImage) {
        super.init(frame: .zero)
        addSubview(imageView)
        currentImage = content
        imageView.image = content
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentImage: UIImage? {
        willSet {
            if !mosaicUndoManager.isUndoing {
                mosaicUndoManager.registerUndo(withTarget: self, selector: #selector(undoDraw(_:)), object: currentImage)
            } else {
                mosaicLayer.mask = XHLayer(frame: bounds)
            }
        }
        didSet {
            imageView.image = currentImage
            maskLayer = nil
            path = nil
        }
    }
    
    private lazy var mosaicLayer: CALayer = {
        let temp = CALayer()
        temp.frame = bounds
        if let image = imageView.image {
            let scale = image.size.width / bounds.width / UIScreen.main.scale * 20
            temp.contents = image.mosaic(for: Int(scale))?.cgImage
        }
        layer.addSublayer(temp)
        return temp
    }()
    
    private var maskLayer: XHLayer?
    
    private var path: CGMutablePath?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        delegate?.mosaicViewDidBeginDrawing(self)
        let maskLayer = XHLayer(frame: bounds)
        layer.addSublayer(maskLayer)
        mosaicLayer.mask = maskLayer
        maskLayer.lineWidth /= scale
        self.maskLayer = maskLayer
        let point = touch.location(in: self)
        path = CGMutablePath()
        path?.move(to: point)
        maskLayer.path = path
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        path?.addLine(to: point)
        maskLayer?.path = path
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        path?.addLine(to: point)
        maskLayer?.path = path
        currentImage = snapImage()
        delegate?.mosaicViewDidEndDrawing(self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        path?.addLine(to: point)
        maskLayer?.path = path
        currentImage = snapImage()
        delegate?.mosaicViewDidEndDrawing(self)
    }
    
    private lazy var mosaicUndoManager = UndoManager()
    
    func undo() {
        mosaicUndoManager.undo()
    }
    
    var canUndo: Bool {
        return mosaicUndoManager.canUndo
    }
    
    @objc private func undoDraw(_ image: UIImage?) {
        currentImage = image
    }
    
    override var intrinsicContentSize: CGSize {
        return imageView.intrinsicContentSize
    }
    
    private class XHLayer: CAShapeLayer {
        
        init(frame: CGRect) {
            super.init()
            self.frame = frame
            lineCap = .round
            lineJoin = .round
            lineWidth = 20
            fillColor = nil
            strokeColor = UIColor.red.cgColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}

protocol XHMosaicViewDelegate: NSObjectProtocol {
    
    func mosaicViewDidBeginDrawing(_ mosaicView: XHMosaicView)
    
    func mosaicViewDidEndDrawing(_ mosaicView: XHMosaicView)
    
}

fileprivate extension UIImage {
    
    func mosaic(for level: Int) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = cgImage.width
        let height = cgImage.height
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let bitmapData = context.data else { return nil }
        let pixel = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 1)
        for y in 0 ..< height {
            for x in 0 ..< width {
                let index = width * y + x
                if y % level == 0 {
                    if x % level == 0 {
                        memcpy(pixel, bitmapData + index * 4, 4)
                    } else {
                        memcpy(bitmapData + index * 4, pixel, 4)
                    }
                } else {
                    let topIndex = width * (y - 1) + x
                    memcpy(bitmapData + index * 4, bitmapData + topIndex * 4, 4)
                }
            }
        }
        pixel.deallocate()
        let length = width * height * 4
        let newdata = UnsafePointer<UInt8>(OpaquePointer(bitmapData))
        guard let data = CFDataCreate(kCFAllocatorDefault, newdata, length) else { return nil }
        let provider = CGDataProvider(data: data)
        guard let result = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: 1), provider: provider!, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return nil}
        let outputContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: 1)
        outputContext?.draw(result, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        return UIImage(cgImage: result, scale: UIScreen.main.scale, orientation: .up)
    }
    
}
