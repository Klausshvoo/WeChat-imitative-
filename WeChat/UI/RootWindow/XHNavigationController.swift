//
//  XHNavigationController.swift
//  WeChat
//
//  Created by Li on 2018/7/11.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private(set) var isPushing: Bool = false
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard !isPushing else { return }
        isPushing = true
        if !viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
        DispatchQueue.main.asyncAfter(deadline: .now() +  0.25) {[weak self] in
            self?.isPushing = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

class XHBlackNavigationController: XHNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlackBar()
    }
    
}

extension UIBarButtonItem {
    
    convenience init(image: UIImage? = nil,title: String? = nil,target: Any?,action: Selector) {
        let button = UIButton(type: .custom)
        if let title = title {
            button.setTitle(title, for: .normal)
        }
        if let image = image {
            button.setImage(image, for: .normal)
        }
        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()
        self.init(customView: button)
    }
    
}

extension UINavigationController {
    
    func setBlackBar() {
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,.font: UIFont.boldSystemFont(ofSize: 20)]
        navigationBar.barStyle = .black
        navigationBar.barTintColor = UIColor.black
        let item = UIBarButtonItem.appearance(whenContainedInInstancesOf: [type(of: self)])
        item.setTitleTextAttributes([.foregroundColor: UIColor.white,.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        item.tintColor = UIColor.white
    }
    
}

