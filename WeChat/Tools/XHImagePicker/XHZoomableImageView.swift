//
//  XHZoomableImageView.swift
//  WeChat
//
//  Created by Li on 2018/9/8.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHZoomableImageView: UIView {

    private let scrollView = UIScrollView()
    
    private let imageView = XHImageView()
    
    private var scrollWidthConstraint: NSLayoutConstraint!
    
    private var scrollHeightContraint: NSLayoutConstraint!
    
    /// defaule is 1
    var maximumZoomScale: CGFloat {
        set {
            scrollView.maximumZoomScale = newValue
        }
        get {
            return scrollView.maximumZoomScale
        }
    }
    
    /// default is 1
    var minimumZoomScale: CGFloat {
        set {
            scrollView.minimumZoomScale = newValue
        }
        get {
            return scrollView.minimumZoomScale
        }
    }
    
    /// default is minimumZoomScale
    var zoomScale: CGFloat {
        set {
            scrollView.zoomScale = newValue
        }
        get {
            return scrollView.zoomScale
        }
    }
    
    private(set) lazy var doubleTapGestureRecognizer = UITapGestureRecognizer(target:self , action: #selector(handleDouble))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        scrollWidthConstraint = scrollView.widthAnchor.constraint(equalToConstant: 100)
        scrollWidthConstraint.isActive = true
        scrollWidthConstraint.priority = .defaultLow
        scrollView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
        scrollHeightContraint = scrollView.heightAnchor.constraint(equalToConstant: 100)
        scrollHeightContraint.isActive = true
        scrollHeightContraint.priority = .defaultLow
        scrollView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        scrollView.delegate = self
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var image: UIImage? {
        set {
            imageView.image = newValue
            scrollWidthConstraint.constant = imageView.intrinsicContentSize.width
            scrollHeightContraint.constant = imageView.intrinsicContentSize.height
        }
        get {
            return imageView.image
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
    
    @objc private func handleDouble() {
        if scrollView.zoomScale != scrollView.maximumZoomScale {
            scrollView.zoomScale = scrollView.maximumZoomScale
        } else {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
    }
    
}

extension XHZoomableImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollWidthConstraint.constant = imageView.frame.width
        scrollHeightContraint.constant  = imageView.frame.height
    }
    
}
