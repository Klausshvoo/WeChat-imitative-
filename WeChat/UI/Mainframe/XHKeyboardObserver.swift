//
//  XHKeyboardObserver.swift
//  WeChat
//
//  Created by Li on 2018/7/20.
//  Copyright © 2018年 Li. All rights reserved.
//

import Foundation

@objc protocol XHKeyboardObserver: NSObjectProtocol {
    
    @objc func keyboardWillShow(_ noti: Notification)
    
    @objc func keyboardWillHide(_ noti: Notification)
    
}

extension XHKeyboardObserver {
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
}
