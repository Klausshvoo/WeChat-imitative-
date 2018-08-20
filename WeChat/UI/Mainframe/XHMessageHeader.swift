//
//  XHMessageHeader.swift
//  WeChat
//
//  Created by Li on 2018/7/29.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHMessageHeader: UITableViewHeaderFooterView {
    
    private let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.background
        let imageView = UIImageView(image: #imageLiteral(resourceName: "translation_bg").resizableImage(withCapInsets: UIEdgeInsetsMake(4, 4, 4, 4), resizingMode: .stretch))
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.white
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 8).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }

}
