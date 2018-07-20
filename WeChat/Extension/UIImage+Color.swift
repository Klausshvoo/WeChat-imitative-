//
//  UIImage+Color.swift
//  WeChat
//
//  Created by Li on 2018/7/12.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init?(color: UIColor,for size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext();
            return nil
        }
        self.init(cgImage: image.cgImage!)
    }
    
}
