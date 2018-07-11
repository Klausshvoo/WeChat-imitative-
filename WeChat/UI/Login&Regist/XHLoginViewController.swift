//
//  XHLoginViewController.swift
//  WeChat
//
//  Created by Li on 2018/7/10.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHLoginViewController: UIViewController {
    
    private let scrollView = UIScrollView(frame: UIScreen.main.bounds)
    
    private let phoneLoginView = XHLoginView(style: .phone)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        configureNavigationBar()
        configureSubviews()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "closebtn"), style: .plain, target: self, action: #selector(closeCurrentPage))
    }
    
    @objc private func closeCurrentPage() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(phoneLoginView)
        scrollView.alwaysBounceVertical = true
        phoneLoginView.translatesAutoresizingMaskIntoConstraints = false
        phoneLoginView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        phoneLoginView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        phoneLoginView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 84).isActive = true
        phoneLoginView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,constant: -50).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    enum XHLoginStyle {
        case phone,other
    }
    
    class XHLoginView: UIView {
        
        private let titleLabel = UILabel()
        
        private(set) var style: XHLoginStyle
        
        init(style: XHLoginStyle) {
            self.style = style
            super.init(frame: .zero)
            configureSubviews()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configureSubviews() {
            addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin).isActive = true
            titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            titleLabel.font = UIFont.systemFont(ofSize: 25)
            switch style {
            case .phone:
                titleLabel.text = "手机号登录"
                let areaButton = UIButton(type: .custom)
                addSubview(areaButton)
                areaButton.translatesAutoresizingMaskIntoConstraints = false
                areaButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                areaButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                areaButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
                areaButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true
                areaButton.setImage(#imageLiteral(resourceName: "Card_ArrowGrey"), for: .normal)
                areaButton.contentHorizontalAlignment = .right
                areaButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: edgeMargin)
                addLine().bottomAnchor.constraint(lessThanOrEqualTo: areaButton.bottomAnchor).isActive = true
                let leftLabel = addLabel()
                leftLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin).isActive = true
                leftLabel.centerYAnchor.constraint(equalTo: areaButton.centerYAnchor).isActive = true
                leftLabel.text = "国家/地区"
                let rightLabel = addLabel()
                rightLabel.leftAnchor.constraint(equalTo: leftLabel.rightAnchor, constant: edgeMargin).isActive = true
                rightLabel.centerYAnchor.constraint(equalTo: leftLabel.centerYAnchor).isActive = true
                rightLabel.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -edgeMargin).isActive = true
                rightLabel.adjustsFontSizeToFitWidth = true
                rightLabel.text = "中国"
                let leftTF = addTextField()
                leftTF.leftAnchor.constraint(equalTo: leftLabel.leftAnchor).isActive = true
                leftTF.rightAnchor.constraint(equalTo: leftLabel.rightAnchor).isActive = true
                leftTF.heightAnchor.constraint(equalToConstant: 44).isActive = true
                leftTF.topAnchor.constraint(equalTo: areaButton.bottomAnchor).isActive = true
                leftTF.text = "+86"
                leftTF.delegate = self
                let vLine = UIView()
                addSubview(vLine)
                vLine.translatesAutoresizingMaskIntoConstraints = false
                vLine.leftAnchor.constraint(equalTo: leftTF.rightAnchor).isActive = true
                vLine.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
                vLine.heightAnchor.constraint(equalTo: leftTF.heightAnchor).isActive = true
                vLine.topAnchor.constraint(equalTo: leftTF.topAnchor).isActive = true
                vLine.backgroundColor = UIColor.sepLine
                addLine().bottomAnchor.constraint(equalTo: leftTF.bottomAnchor).isActive = true
                
                leftTF.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            case .other:
                titleLabel.text = "微信号/QQ号/邮箱登录"
            }
            
        }
        
        private func addLine() -> UIView {
            let line = UIView()
            addSubview(line)
            line.translatesAutoresizingMaskIntoConstraints = false
            line.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin).isActive = true
            line.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeMargin).isActive = true
            line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            line.backgroundColor = UIColor.sepLine
            return line
        }
        
        private func addLabel() -> UILabel {
            let label = UILabel()
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 20)
            return label
        }
        
        private func addTextField() -> UITextField {
            let textField = UITextField()
            addSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.textColor = UIColor.black
            textField.font = UIFont.systemFont(ofSize: 20)
            return textField
        }
        
        
        
    }

}

extension XHLoginViewController.XHLoginView: UITextFieldDelegate {
    
}
