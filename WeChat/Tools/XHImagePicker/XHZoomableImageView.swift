//
//  XHZoomableImageView.swift
//  WeChat
//
//  Created by Li on 2018/9/8.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHZoomableImageView: XHZoomableView {
    
    init(frame: CGRect) {
        super.init(frame: frame, zoomView: XHImageView())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var image: UIImage? {
        set {
            if let imageView = zoomView as? XHImageView {
                imageView.image = newValue
                setZoomSize(imageView.intrinsicContentSize)
            }
        }
        get {
            if let imageView = zoomView as? XHImageView {
                return imageView.image
            }
            return nil
        }
    }
    
    fileprivate class XHImageView: UIImageView {
        
        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            let width = min(size.width, UIScreen.main.bounds.width - 20)
            let scale = size.width / width
            let height = size.height / scale
            return CGSize(width: width, height: height)
        }
    }
    
}

