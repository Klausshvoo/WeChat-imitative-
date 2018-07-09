//
//  XHWindow.swift
//  WeChat
//
//  Created by Li on 2018/7/9.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHWindow: UIWindow {
    
    func configureRootController() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        if let isIntroduce = UserDefaults.standard.string(forKey: "NewVersionIntroduction"),isIntroduce == version {
            
        } else {
            let introductionController = XHIntroductionController()
            introductionController.delegate = self
        }
    }
    
}

extension XHWindow: XHIntroductionControllerDelegate {
    
    func introductionControllerDidEndIntroduce(_ controller: XHIntroductionController) {
        
    }
    
}
