//
//  XHTabBarController.swift
//  WeChat
//
//  Created by Li on 2018/7/9.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        tabBar.backgroundImage = #imageLiteral(resourceName: "tabbarBkg")
        let item = UITabBarItem.appearance()
        item.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12),.foregroundColor: UIColor.main], for: .selected)
        item.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12),.foregroundColor: UIColor.grayText], for: .normal)
        configureChildrenControllers()
    }
    
    private func configureChildrenControllers() {
        configureChildController(XHMainframeController(), imageName: "mainframe", title: "微信")
        configureChildController(XHContactsController(), imageName: "contacts", title: "联系人")
        configureChildController(XHDiscoverController(), imageName: "discover", title: "发现")
        configureChildController(XHMeController(), imageName: "me", title: "我的")
    }

    private func configureChildController(_ controller: UIViewController,imageName: String,title: String) {
        let navgationController = XHBlackNavigationController(rootViewController: controller)
        controller.tabBarItem.selectedImage = UIImage(named: "tabbar_\(imageName)HL")
        controller.tabBarItem.image = UIImage(named: "tabbar_\(imageName)")
        controller.tabBarItem.title = title
        addChildViewController(navgationController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


