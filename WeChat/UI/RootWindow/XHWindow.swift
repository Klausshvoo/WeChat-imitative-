//
//  XHWindow.swift
//  WeChat
//
//  Created by Li on 2018/7/9.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHWindow: UIWindow {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rootViewController = XHTabBarController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class XHLoginWindow: UIWindow {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rootViewController = XHRootViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignKey() {
        super.resignKey()
        rootViewController?.dismiss(animated: false, completion: {[weak self] in
            self?.isHidden = true
        })
    }
    
}

