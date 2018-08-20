//
//  UITableView+Update.swift
//  WeChat
//
//  Created by Li on 2018/7/28.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

extension UITableView {
    
    func update(_ updates:() -> Void,completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 11.0, *) {
            performBatchUpdates(updates, completion: completion)
        } else {
            beginUpdates()
            updates()
            endUpdates()
            completion?(true)
        }
    }
    
}
