//
//  String+Emotion.swift
//  WeChat
//
//  Created by Li on 2018/7/30.
//  Copyright © 2018年 Li. All rights reserved.
//

import Foundation
import UIKit

enum StringTransferredRule: String {
    
    // 格式@xxx+空格
    case at = "@[0-9a-zA-Z\\u4e00-\\u9fa5]+ "
    
    case phoneNo = "1[3|4|5|7|8|9][0-9]\\d{8}"
    
    case emotion = "\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
    
    case link = "http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?"
    
}

extension String {
    
    func transferred(rules: [StringTransferredRule]) -> NSAttributedString {
        let temp = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        temp.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, count))
        return temp.transferred(rules:rules)
    }
    
}

extension NSAttributedString {
    
    func transferred(rules: [StringTransferredRule]) -> NSAttributedString {
        var temp = NSMutableAttributedString(attributedString: self)
        var range: NSRange = NSMakeRange(0, 0)
        var attributes = temp.attributes(at: 0, effectiveRange: &range)
        if let paragraphStyle = attributes[.paragraphStyle] as? NSParagraphStyle,paragraphStyle.lineBreakMode != .byWordWrapping {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            temp.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        }
        for rule in rules {
            temp = temp.regular(rule: rule)! as! NSMutableAttributedString
        }
        return temp
    }
    
    private func regular(rule: StringTransferredRule) -> NSAttributedString? {
        let range = NSMakeRange(0, string.count)
        let temp = NSMutableAttributedString(attributedString: self)
        do {
            let regular = try NSRegularExpression(pattern: rule.rawValue, options: .dotMatchesLineSeparators)
            let results = regular.matches(in: string, options: .reportProgress, range: range).reversed()
            for result in results {
                switch rule {
                case .at:
                    temp.addAttribute(.foregroundColor, value: UIColor.red, range: result.range)
                    print("@:\(result.range)")
                case .phoneNo,.link :
                    temp.addAttribute(.foregroundColor, value: UIColor.green, range: result.range)
                    print("phone:\(result.range)")
                case .emotion:
                    let emotionTitle = (string as NSString).substring(with: result.range)
                    let filter = XHEmotionBag.defaultBag.emotions.filter({ $0.title == emotionTitle })
                    if let emotion = filter.first,let title = emotion.title,title == emotionTitle {
                        let textAttachment = NSTextAttachment()
                        textAttachment.image = UIImage(named: emotion.imageName!)
                        temp.replaceCharacters(in: result.range, with: NSAttributedString(attachment: textAttachment))
                    } else {
                        continue
                    }
                }
            }
            return temp
        } catch {
            print("正则表达式错误")
            return nil
        }
    }
    
}
