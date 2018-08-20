//
//  XHMessageTranspondable.swift
//  WeChat
//
//  Created by Li on 2018/7/30.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

protocol XHMessageTranspondable {
    
    func presentedViewControllerForTranspond() -> UIViewController
    
}

extension XHMessageTranspondable {
    
    func transpond(_ message: XHMessage) {
        let viewController = presentedViewControllerForTranspond()
        let transpondController = XHFriendSelectController()
        transpondController.message = message
        viewController.present(transpondController, animated: true, completion: nil)
    }
    
}
