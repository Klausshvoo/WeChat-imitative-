//
//  XHChatViewController.swift
//  WeChat
//
//  Created by Li on 2018/7/18.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHChatViewController: UIViewController {
    
    var messageCollection: XHMessageCollection!
    
    private let chatBar = XHChatBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        configureNavigationBar()
        configureChatBar()
        registerKeyboardNotifications()
    }
    
    // MARK: - NavigationBar
    private func configureNavigationBar() {
        title = messageCollection.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_more"), style: .plain, target: self, action: #selector(showChatInfo))
    }
    
    @objc private func showChatInfo() {
        
    }
    
    // MARK: - ChatBar
    private func configureChatBar() {
        view.addSubview(chatBar)
        chatBar.translatesAutoresizingMaskIntoConstraints = false
        chatBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        chatBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        chatBar.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        removeKeyboardNotifications()
    }

}

extension XHChatViewController: XHKeyboardObserver {
    
    func keyboardWillShow(_ noti: Notification) {
        if let info = noti.userInfo,let frame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            var y = frame.height
            if #available(iOS 11.0, *) {
                y -= view.safeAreaInsets.bottom
            }
            chatBar.transform = CGAffineTransform(translationX: 0, y: -y)
        }
    }
    
    func keyboardWillHide(_ noti: Notification) {
        if let info = noti.userInfo,let frame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            chatBar.transform = .identity
        }
    }
    
}



