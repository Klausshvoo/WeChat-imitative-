//
//  XHKeyboardObserver.swift
//  WeChat
//
//  Created by Li on 2018/7/20.
//  Copyright © 2018年 Li. All rights reserved.
//

import Foundation
import UIKit

@objc protocol XHKeyboardObserver: NSObjectProtocol {
    
    @objc func keyboardWillShow(_ noti: Notification)
    
    @objc func keyboardWillHide(_ noti: Notification)
    
}

extension XHKeyboardObserver {
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}
