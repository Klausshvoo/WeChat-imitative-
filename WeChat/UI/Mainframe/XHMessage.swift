//
//  XHMessage.swift
//  WeChat
//
//  Created by Li on 2018/7/17.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

enum XHMessageType: Int,Codable {
    case text,image,video,audio,expression
}

class XHMessage: NSObject,Codable {
    
    fileprivate(set) var type: XHMessageType = .text
    
    fileprivate(set) var sourceMember: XHFriend?
    
    var abstract: String  {
        switch type {
        case .text:
            return (self as! XHTextMessage).content
        case .image:
            return "[图片]"
        case .video:
            return "[视频]"
        case .audio:
            return "[语音]"
        case .expression:
            return "[表情]"
        }
    }
    
    fileprivate(set) var timeInterval: TimeInterval = 0
    
    var time: String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return date.adjustStringValue(options: [.date])
    }

}

class XHTextMessage: XHMessage {
    
    private(set) var content: String = ""
    
    init(content: String) {
        self.content = content
        super.init()
        type = .text
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
