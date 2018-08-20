//
//  XHUser.swift
//  WeChat
//
//  Created by Li on 2018/7/17.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

enum XHSex: Int,Codable {
    case woman,man
}

class XHUser: NSObject,Codable {
    
    /// 昵称
    private(set) var nickName: String = ""
    
    /// 头像地址
    private(set) var avatarUrl: String?
    
    /// 性别
    private(set) var sex: XHSex = .woman
    
    /// 微信号
    private(set) var wxCode: String?
    
    /// 地址
    private(set) var address: String = "中国"

}

enum XHFriendSourceType: Int,Codable {
    case wxCode,phoneNo,qq
}

class XHFriend: XHUser {
    
    /// 备注
    var markName: String?
    
    /// 星标朋友
    var isStar: Bool = false
    
    /// 添加来源
    private(set) var sourceType: XHFriendSourceType = .wxCode
    
}

class XHMainUser: XHUser {
    
    var expressionCollections: [XHEmotionBag]?
    
}
