//
//  XHMessageCollection.swift
//  WeChat
//
//  Created by Li on 2018/7/17.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

enum XHMessageCollectionType: Int,Codable {
    case chat,groupChat
}

class XHMessageCollection: NSObject,Codable {
    
    private(set) var type: XHMessageCollectionType = .chat
    
    private(set) var isHighLight: Bool = false
    
    private(set) var isUndisturbed: Bool = false
    
    private(set) var abstract: String?
    
    private(set) var time: String?
    
    private(set) var avatarUrl: String?
    
    private(set) var name: String!
    
    var unreadCount: Int = 0
    
    //单聊code为目标人code，其他为后台计算的code；单聊情况下可直接在本地生成code
    private(set) var code: String = ""
    
    /// 提示：譬如:[草稿]，该属性为本地属性，不与服务器交互
    var tips: String?
    
    static func defaultColletions() -> [XHMessageCollection] {
        let chat = XHMessageCollection()
        chat.type = .chat
        chat.abstract = "这是测试数据"
        chat.time = "10:35"
        chat.name = "小明"
        chat.unreadCount = 3
        let group = XHMessageCollection()
        group.type = .groupChat
        group.abstract = "小红:这是群聊测试数据"
        group.time = "10:35"
        group.name = "群聊测试"
        group.unreadCount = 3
        group.isUndisturbed = true
        return [chat,group]
    }
    
}
