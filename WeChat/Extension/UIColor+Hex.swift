//
//  UIColor+Hex.swift
//  WeChat
//
//  Created by Li on 2018/7/9.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: UInt32,alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xff00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xff) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static let main = UIColor(hex: 0x26ab28)
    
    static let background = UIColor(hex: 0xf8f8f8)
    
    static let grayText = UIColor(hex: 0xb7b2b6)
    
    static let sepLine = UIColor(hex: 0xe4e4e4)
    
}
