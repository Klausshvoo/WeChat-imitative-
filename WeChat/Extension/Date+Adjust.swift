//
//  Date+Adjust.swift
//  WeChat
//
//  Created by Li on 2018/7/17.
//  Copyright © 2018年 Li. All rights reserved.
//

import Foundation

/// rawValue越大，优先级越高
struct XHDateAdjustOption: OptionSet {
    
    public var rawValue: UInt
    
    /// 同年不显示年，只显示月-日 时:分，否则只显示年月日
    static let year = XHDateAdjustOption(rawValue: 1 << 0)
    
    /// 一周之内显示几天前,若同时设定了yesterday，那么昨天会显示为昨天
    static let week = XHDateAdjustOption(rawValue: 1 << 1)
    
    /// 昨天显示昨天，若同时设定了date，会显示为昨天 时:分
    static let yesterday = XHDateAdjustOption(rawValue: 1 << 2)
    
    /// 同年月日不显示年月日，只显示时:分
    static let date = XHDateAdjustOption(rawValue: 1 << 3)
    
    /// 24小时内显示几小时前，若超出24小时，则不再计算
    static let hour = XHDateAdjustOption(rawValue: 1 << 4)
    
    /// 1小时内显示几分钟前，若小于1分钟，则显示刚刚，若超出1小时，则不再计算
    static let minite = XHDateAdjustOption(rawValue: 1 << 5)
    
}

extension Date {
    
    /// 按照formatter格式转化当前时间为字符串,timeZone为空时，默认为iPhone所设置的时区
    func stringValue(_ formatter: String,timeZone: TimeZone? = nil) -> String {
        let dateFormatter = DateFormatter()
        if let timeZone = timeZone {
            dateFormatter.timeZone = timeZone
        }
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: self)
    }
    
    /// 按照“yyyy-MM-dd HH:mm”格式转化当前时间为字符串，timeZone为空时，默认为iPhone所设置的时区
    /// 自适应当前时间，options参数来限定如何进行自适应
    func adjustStringValue(_ timeZone: TimeZone? = nil,options: XHDateAdjustOption) -> String {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(self)
        let minites = timeInterval / 60
        if options.contains(.minite),minites < 60 {
            return minites < 1 ? "刚刚" :"\(Int(minites))分钟前"
        }
        let hours = minites / 60
        if options.contains(.hour),hours < 24 {
            return "\(Int(hours))小时前"
        }
        let current = currentDate.stringValue("yyyy-MM-dd HH:mm", timeZone: timeZone)
        let temp = stringValue("yyyy-MM-dd HH:mm", timeZone: timeZone)
        if options.contains(.date) {
            let currentDate = String(current[current.startIndex ..< current.index(current.startIndex, offsetBy: 10)])
            let date = String(temp[temp.startIndex ..< temp.index(temp.startIndex, offsetBy: 10)])
            if date == currentDate {
                return String(temp[temp.index(temp.startIndex, offsetBy: 11) ..< temp.endIndex])
            }
        }
        let days = hours / 24
        if options.contains(.yesterday),days < 2 {
            return options.contains(.date) ? "昨天 \(temp[temp.index(temp.startIndex, offsetBy: 11) ..< temp.endIndex])" : "昨天"
        }
        if options.contains(.week),days < 7 {
            return options.contains(.date) ? "\(Int(days))天前 \(temp[temp.index(temp.startIndex, offsetBy: 11) ..< temp.endIndex])" : "\(Int(days))天前"
        }
        if options.contains(.year) {
            let currentYear = String(current[current.startIndex ..< current.index(current.startIndex, offsetBy: 4)])
            let year = String(temp[temp.startIndex ..< temp.index(temp.startIndex, offsetBy: 4)])
            if year == currentYear {
                return String(temp[temp.index(temp.startIndex, offsetBy: 5) ..< temp.endIndex])
            } else {
                return String(temp[temp.startIndex ..< temp.index(temp.startIndex, offsetBy: 10)])
            }
        }
        return temp
    }
}
