//
//  XHZoomableView.swift
//  WeChat
//
//  Created by Li on 2018/9/23.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHZoomableView: UIView {
    
    private let scrollView = UIScrollView()
    
    private(set) var zoomView: UIView
    
    private var scrollWidthConstraint: NSLayoutConstraint!
    
    private var scrollHeightContraint: NSLayoutConstraint!
    
    @available(iOS 11.0, *)
    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        set {
            scrollView.contentInsetAdjustmentBehavior = newValue
        }
        get {
            return scrollView.contentInsetAdjustmentBehavior
        }
    }
    
    var isScrollEnabled: Bool {
        set {
            scrollView.isScrollEnabled = newValue
        }
        get {
            return scrollView.isScrollEnabled
        }
    }
    
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
    
    weak var delegate: XHZoomableViewDelegate?
    
    private(set) lazy var doubleTapGestureRecognizer = UITapGestureRecognizer(target:self , action: #selector(handleDouble))
    
    @objc private func handleDouble() {
        if scrollView.zoomScale != scrollView.maximumZoomScale {
            scrollView.zoomScale = scrollView.maximumZoomScale
        } else {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
    }
    
    /// 初始化方法
    ///
    /// - Parameter zoomView: 该参数必须包含自身大小
    init(frame: CGRect,zoomView: UIView) {
        self.zoomView = zoomView
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        scrollView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor).isActive = true
        scrollView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
        scrollWidthConstraint = scrollView.widthAnchor.constraint(equalToConstant: zoomView.bounds.width)
        scrollWidthConstraint.priority = .defaultLow
        scrollWidthConstraint.isActive = true
        scrollHeightContraint = scrollView.heightAnchor.constraint(equalToConstant: zoomView.bounds.height)
        scrollHeightContraint.priority = .defaultLow
        scrollHeightContraint.isActive = true
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(zoomView)
        zoomView.translatesAutoresizingMaskIntoConstraints = false
        zoomView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        zoomView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        zoomView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        zoomView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final func setZoomSize(_ size: CGSize) {
        scrollWidthConstraint.constant = size.width
        scrollHeightContraint.constant  = size.height
    }
    
}

extension XHZoomableView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setZoomSize(zoomView.frame.size)
        delegate?.zoomableViewDidZoom?(self)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        delegate?.zoomableView?(self, didEndZoomingAtScale: scale)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.zoomableViewWillBeginZooming?(self)
    }
    
}

@objc protocol XHZoomableViewDelegate: NSObjectProtocol {
    
    @objc optional func zoomableViewDidZoom(_ zoomableView: XHZoomableView)
    
    @objc optional func zoomableView(_ zoomableView: XHZoomableView,didEndZoomingAtScale scale: CGFloat)
    
    @objc optional func zoomableViewWillBeginZooming(_ zoomableView: XHZoomableView)
    
}
