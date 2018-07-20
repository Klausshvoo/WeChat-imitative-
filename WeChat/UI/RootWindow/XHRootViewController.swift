//
//  XHRootViewController.swift
//  WeChat
//
//  Created by Li on 2018/7/11.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHRootViewController: UIViewController {
    
    private let imageView = UIImageView(frame: UIScreen.main.bounds)
    
    private let loginButton = UIButton(type: .custom)
    
    private let registButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        imageView.image = UIImage.launchImage()
        view.addSubview(imageView)
        configureButton(loginButton, with: 0)
        configureButton(registButton, with: 1)
    }
    
    private func configureButton(_ button: UIButton,with tag: Int) {
        view.addSubview(button)
        button.tag = tag
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -edgeMargin * 2).isActive = true
        if tag == 0 {
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: edgeMargin * 2).isActive = true
            button.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -edgeMargin).isActive = true
            button.setTitle("登录", for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.backgroundColor = UIColor.background
        } else {
            button.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: edgeMargin).isActive = true
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -edgeMargin * 2).isActive = true
            button.setTitle("注册", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.backgroundColor = UIColor.main
        }
        button.addTarget(self, action: #selector(handleAction(_:)), for: .touchUpInside)
    }
    
    @objc private func handleAction(_ sender: UIButton) {
        var navigationController: UINavigationController
        if sender.tag == 0 {
            navigationController = XHNavigationController(rootViewController: XHLoginViewController())
        } else {
            navigationController = XHNavigationController(rootViewController: UIViewController())
        }
        present(navigationController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


extension UIImage {
    
    static func launchImage() -> UIImage? {
        if let info = Bundle.main.infoDictionary,let images = info["UILaunchImages"] as? [[String: Any]] {
            let filter = images.filter { (dic) -> Bool in
                if let sizeString = dic["UILaunchImageSize"] as? String {
                    let size = CGSizeFromString(sizeString)
                    if size == UIScreen.main.bounds.size, let orientation = dic["UILaunchImageOrientation"] as? String, orientation == "Portrait" {
                        return true
                    }
                }
                return false
            }
            if let imageDic = filter.first,let imageName = imageDic["UILaunchImageName"] as? String {
                return UIImage(named: imageName)
            }
        }
        return nil
    }
    
}
