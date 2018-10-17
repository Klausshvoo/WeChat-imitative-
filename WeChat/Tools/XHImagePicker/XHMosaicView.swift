//
//  XHMosaicView.swift
//  WeChat
//
//  Created by Li on 2018/10/15.
//  Copyright © 2018 Li. All rights reserved.
//

import UIKit

enum XHMosaicType: Int,CaseIterable {
    case mosaic,blurry
}

class XHMosaicView: UIView {
    
    var scale: CGFloat = 1
    
    weak var delegate: XHMosaicViewDelegate?
    
    var type: XHMosaicType = .mosaic {
        didSet {
            guard type != oldValue else { return }
            guard let mosaicLayer = _mosaicLayer else { return }
            switch type {
            case .mosaic:
                mosaicLayer.contents = mosaicImage?.cgImage
            case .blurry:
                mosaicLayer.contents = blurryImage?.cgImage
            }
            mosaicLayer.mask = XHLayer(frame: bounds)
        }
    }

    private let imageView = UIImageView()
    
    private var image: UIImage
    
    init(content: UIImage) {
        image = content
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
    
    private lazy var mosaicImage: UIImage? = {
        let scale = image.size.width / bounds.width / UIScreen.main.scale * 20
        return image.mosaic(for: Int(scale))
    }()
    
    private lazy var blurryImage: UIImage? = image.blurry(for: 0.8)
    
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
    
    private var _mosaicLayer: CALayer?
    
    private lazy var mosaicLayer: CALayer = {
        let temp = CALayer()
        temp.frame = bounds
        switch type {
        case .mosaic:
            temp.contents = mosaicImage?.cgImage
        case .blurry:
            temp.contents = blurryImage?.cgImage
        }
        layer.addSublayer(temp)
        _mosaicLayer = temp
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
            strokeColor = UIColor.blue.cgColor
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
    
    /// 获取图片马赛克效果
    ///
    /// - Parameter level: 与像素相关，必须大于0
    /// - Returns: a new UIImage object
    func mosaic(for level: Int) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = cgImage.width
        let height = cgImage.height
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return nil }
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
        guard let result = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: cgImage.bitmapInfo, provider: provider!, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return nil}
        let outputContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: 1)
        outputContext?.draw(result, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        return UIImage(cgImage: result, scale: UIScreen.main.scale, orientation: .up)
    }
    
}

import Accelerate

extension UIImage {
    
    /// 获取图片高斯模糊效果
    ///
    /// - Parameter level: 模糊等级，bounds 0 ... 1
    /// - Returns: a new UIImage object
    func blurry(for level: CGFloat) -> UIImage? {
        guard level > 0 && level < 1 else { return nil }
        guard let cgImage = self.cgImage else { return nil }
        var boxSize = UInt32(level * 100)
        boxSize = boxSize - boxSize % 2 + 1
        guard let provider = cgImage.dataProvider else { return nil }
        guard let bitmapData = provider.data else { return nil }
        let data = UnsafeMutablePointer(mutating: CFDataGetBytePtr(bitmapData))
        var inBuffer = vImage_Buffer(data: data, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.bytesPerRow)
        guard let pixelBuffer = malloc(cgImage.bytesPerRow * cgImage.height) else { return nil }
        var outBuffer = vImage_Buffer(data: pixelBuffer, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.bytesPerRow)
        let error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, boxSize, boxSize, nil, vImage_Flags(kvImageEdgeExtend))
        guard error == kvImageNoError else { return nil }
        guard let colorSpace = cgImage.colorSpace else { return nil }
        guard let context = CGContext(data: outBuffer.data, width: cgImage.width, height: cgImage.height, bitsPerComponent: 8, bytesPerRow: outBuffer.rowBytes, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return nil }
        guard let cgResult = context.makeImage() else { return nil }
        pixelBuffer.deallocate()
        return UIImage(cgImage: cgResult)
    }
    
}
//kCGColorSpaceICCBased; kCGColorSpaceModelRGB; sRGB IEC61966-2.1
