//
//  UIMenuControllerEnable.swift
//  WeChat
//
//  Created by Li on 2018/7/29.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

enum UIMenuItemType: String {
    
    case copy,transpond,collect,delete,remind,mutable,addEmotion,emotionBag,edit,earpiecePlay,mutePlay,roolback
    
    var menuItem: UIMenuItem {
        switch self {
        case .copy:
            return UIMenuItem(title: "复制", action: #selector(UIResponder.copyItem(_:)))
        case .transpond:
            return UIMenuItem(title: "转发", action: #selector(UIResponder.transpondItem(_:)))
        case .collect:
            return UIMenuItem(title: "收藏", action: #selector(UIResponder.collectItem(_:)))
        case .delete:
            return UIMenuItem(title: "删除", action: #selector(UIResponder.deleteItem(_:)))
        case .remind:
            return UIMenuItem(title: "提醒", action: #selector(UIResponder.remindItem(_:)))
        case .mutable:
            return UIMenuItem(title: "多选", action: #selector(UIResponder.mutableItem(_:)))
        case .addEmotion:
            return UIMenuItem(title: "添加到表情", action: #selector(UIResponder.addEmotionItem(_:)))
        case .emotionBag:
            return UIMenuItem(title: "查看专辑", action: #selector(UIResponder.emotionBagItem(_:)))
        case .edit:
            return UIMenuItem(title: "编辑", action: #selector(UIResponder.editItem(_:)))
        case .earpiecePlay:
            return UIMenuItem(title: "听筒播放", action: #selector(UIResponder.earpiecePlayItem(_:)))
        case .mutePlay:
            return UIMenuItem(title: "静音播放", action: #selector(UIResponder.mutePlayItem(_:)))
        case .roolback:
            return UIMenuItem(title: "静音播放", action: #selector(UIResponder.roolbackItem(_:)))
        }
    }
    
}

extension UIResponder {
    
    @objc open func copyItem(_ sender: UIMenuController) {}
    
    @objc open func transpondItem(_ sender: UIMenuController) {}
    
    @objc open func collectItem(_ sender: UIMenuController) {}
    
    @objc open func deleteItem(_ sender: UIMenuController) {}
    
    @objc open func remindItem(_ sender: UIMenuController) {}
    
    @objc open func mutableItem(_ sender: UIMenuController) {}
    
    @objc open func addEmotionItem(_ sender: UIMenuController) {}
    
    @objc open func emotionBagItem(_ sender: UIMenuController) {}
    
    @objc open func editItem(_ sender: UIMenuController) {}
    
    @objc open func earpiecePlayItem(_ sender: UIMenuController) {}
    
    @objc open func mutePlayItem(_ sender: UIMenuController) {}
    
    @objc open func roolbackItem(_ sender: UIMenuController) {}
    
    func showMenuController(_ itemTypes: [UIMenuItemType],targetRect rect: CGRect, in view: UIView) -> UIMenuController {
        becomeFirstResponder()
        let menuController = UIMenuController.shared
        var items = [UIMenuItem]()
        for type in itemTypes {
            items.append(type.menuItem)
        }
        menuController.menuItems = items
        menuController.setTargetRect(rect, in: view)
        menuController.setMenuVisible(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(menuControllerShouldDismiss), name: .UIMenuControllerWillHideMenu, object: nil)
        return menuController
    }
    
    func performAction(_ action: Selector) -> Bool {
        if action.description.hasSuffix("Item:") {
            return true
        }
        return false
    }
    
    @objc private func menuControllerShouldDismiss() {
        let menuController = UIMenuController.shared
        menuController.menuItems = nil
        NotificationCenter.default.removeObserver(self, name: .UIMenuControllerWillHideMenu, object: nil)
    }
    
}
