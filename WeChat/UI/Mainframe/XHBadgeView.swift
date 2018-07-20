//
//  XHBadgeView.swift
//  WeChat
//
//  Created by Li on 2018/7/18.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHBadgeView: UIImageView {
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.textColor = UIColor.white
        image = UIImage(color: UIColor(hex: 0xf6383f))
        layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 2).isActive = true
        widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        widthAnchor.constraint(greaterThanOrEqualTo: heightAnchor, multiplier: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var badgeValue: String? {
        set {
            label.text = newValue
        }
        get {
            return label.text
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
}
