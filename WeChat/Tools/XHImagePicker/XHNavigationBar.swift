//
//  XHNavigationBar.swift
//  WeChat
//
//  Created by Li on 2018/9/10.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHNavigationBar: UIView,UIBarPositioning {
    
    var barPosition: UIBarPosition {
        return .top
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 64)
    }
    
    private let toolBar = XHTranslucentToolBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        toolBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var items: [UIBarButtonItem]? {
        set {
            toolBar.items = newValue
        }
        get {
            return toolBar.items
        }
    }
    
    /// as same as backgroudColor
    var barTintColor: UIColor? {
        set {
            backgroundColor = newValue
        }
        get {
            return backgroundColor
        }
    }

}

class XHTranslucentToolBar: UIToolbar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        clearsContextBeforeDrawing = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {}
}
