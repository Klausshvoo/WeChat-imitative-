//
//  XHCommunication.swift
//  WeChat
//
//  Created by Li on 2018/7/17.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHCommunication: NSObject {
    
    private(set) var members: [XHFriend] = []
    
    private(set) var isHighLight: Bool = false
    
    private(set) var isUndisturbed: Bool = false
    
    private(set) var lastMessage: XHMessage?
    
    private(set) var avatarUrl: String?
    
    private(set) var unreadCount: Int = 0
    
    var name: String {
        if let temp = _name {
            return temp
        }
        let names = members.map { (member) -> String in
            if let markName = member.markName {
                return markName
            }
            return member.nickName
        }
        return names.joined(separator: "、")
    }

    private var _name: String?
}
