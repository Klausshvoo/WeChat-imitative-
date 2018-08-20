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
    
    var title: String {
        switch self {
        case .text:
            return "text"
        case .image:
            return "image"
        case .video:
            return "video"
        case .audio:
            return "audio"
        case .expression:
            return "expression"
        }
    }
}

class XHMessage: NSObject {
    
    private(set) var type: XHMessageType
    
    fileprivate(set) var sourceMember: XHFriend?
    
    var abstract: String  {
        return ""
    }
    
    fileprivate(set) var timeInterval: TimeInterval
    
    var time: String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return date.adjustStringValue(options: [.date,.yesterday,.year])
    }
    
    init(type: XHMessageType) {
        self.type = type
        timeInterval = Date().timeIntervalSince1970
        super.init()
    }

}

class XHTextMessage: XHMessage {
    
    private(set) var content: String
    
    private(set) lazy var attributeContent: NSAttributedString = {
        let temp = NSMutableAttributedString(string: content)
        
        return temp
    }()
    
    init(content: String) {
        self.content = content
        super.init(type: .text)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override var abstract: String {
        return content
    }
    
}

class XHEmotionMessage: XHMessage {
    
    private(set) var emotion: XHEmotion
    
    init(emotion: XHEmotion) {
        self.emotion = emotion
        super.init(type: .expression)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override var abstract: String {
        return emotion.title ?? "[动画表情]"
    }
    
}

class XHAudioMessage: XHMessage {
    
    private(set) var duration: TimeInterval
    
    private(set) var path: String
    
    init(path: String,duration: TimeInterval) {
        self.path = path
        self.duration = duration
        super.init(type: .audio)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override var abstract: String {
        return "[语音]"
    }
      
}
