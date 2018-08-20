//
//  XHFriendSelectController.swift
//  WeChat
//
//  Created by Li on 2018/7/30.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHFriendSelectController: XHNavigationController {
    
    var message: XHMessage! {
        didSet {
            if let root = viewControllers[0] as? XHFriendSelectViewController {
                root.message = message
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        pushViewController(XHFriendSelectViewController(), animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

fileprivate class XHFriendSelectViewController: UIViewController {
    
    private var mutable: Bool = false {
        didSet {
            guard mutable != oldValue else { return }
            configureNavigationBar()
        }
    }
    
    fileprivate var message: XHMessage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        configureNavigationBar()
        let label = XHLabel(frame: CGRect(x: 20, y: 100, width: 335, height: 200))
        view.addSubview(label)
        label.numberOfLines = 0
        label.backgroundColor = UIColor.yellow
        if let message = self.message as? XHTextMessage {
            label.text = message.content;
        }
        
    }
    
    private func configureNavigationBar() {
        title = mutable ? "选择多个聊天" : "选择一个聊天"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: mutable ? "取消" : "关闭", style: .plain, target: self, action: #selector(leftNavigationItemResponse))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: mutable ? "取消" : "关闭", style: .plain, target: self, action: #selector(leftNavigationItemResponse))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: mutable ? "完成" : "多选", style: .plain, target: self, action: #selector(rightNavigationItemResponse))
    }
    
    @objc private func leftNavigationItemResponse() {
        if mutable {
            mutable = false
        } else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func rightNavigationItemResponse() {
        if mutable {
            
        } else {
            mutable = true
        }
    }
    
}
