//
//  XHConfig.swift
//  WeChat
//
//  Created by Li on 2018/7/11.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

enum XHLanguage: Int,Codable {
    case chinese,english
}

class XHConfig: NSObject {
    
    static let shared = XHConfig()
    
    private(set) var fontLevel: Int = 0
    
    private(set) var language: XHLanguage = .chinese
    
    func setFontLevel(_ level: Int) {
        fontLevel = level
    }

}

let edgeMargin: CGFloat = 20
