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
    
    private lazy var accountLoginView: XHLoginView = {
        let temp = XHLoginView(style: .other)
        scrollView.addSubview(temp)
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        temp.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        temp.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 84).isActive = true
        return temp
    }()
    
    private let styleButton = UIButton(type: .custom)
    
    private var currentLoginView: XHLoginView!
    
    private let actionButton = UIButton(type: .custom)

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
        phoneLoginView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 0).isActive = true
        scrollView.addSubview(styleButton)
        styleButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: edgeMargin * 2).isActive = true
        styleButton.topAnchor.constraint(equalTo: phoneLoginView.bottomAnchor, constant: 30).isActive = true
        styleButton.setTitle("用微信号/QQ号/邮箱登录", for: .normal)
        styleButton.setTitle("用手机号码登录",for: .selected)
        styleButton.setTitleColor(UIColor(hex: 0x7986a3), for: .normal)
        styleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        styleButton.addTarget(self, action: #selector(changeLoginStyle(_:)), for: .touchUpInside)
        currentLoginView = phoneLoginView
        scrollView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: edgeMargin * 2).isActive = true
        actionButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -edgeMargin * 2).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        actionButton.topAnchor.constraint(equalTo: styleButton.bottomAnchor, constant: 60).isActive = true
        actionButton.isEnabled = false
        actionButton.setTitle("下一步", for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        actionButton.setBackgroundImage(UIImage(color: .main), for: .normal)
        actionButton.layer.cornerRadius = 5
        actionButton.layer.masksToBounds = true
        actionButton.layer.borderColor = UIColor.main.cgColor
        actionButton.layer.borderWidth = 0.5
        actionButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        actionButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        let finePasswordButton = addButton("找回密码")
        finePasswordButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -15).isActive = true
        finePasswordButton.addTarget(self, action: #selector(finePassword), for: .touchUpInside)
        let line = UIView()
        view.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        line.centerYAnchor.constraint(equalTo: finePasswordButton.centerYAnchor).isActive = true
        line.widthAnchor.constraint(equalToConstant: 1).isActive = true
        line.heightAnchor.constraint(equalTo: finePasswordButton.titleLabel!.heightAnchor).isActive = true
        line.backgroundColor = UIColor(hex: 0xa7a7a7)
        let moreButton = addButton("更多选项")
        moreButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 15).isActive = true
        moreButton.addTarget(self, action: #selector(moreOptions), for: .touchUpInside)
    }
    
    private func addButton(_ title: String) -> UIButton {
        let button = UIButton(type: .custom)
        view.addSubview(button)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(UIColor(hex: 0x7986a3), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20).isActive = true
        button.setTitle(title, for: .normal)
        return button
    }
    
    @objc private func changeLoginStyle(_ sender: UIButton) {
        view.endEditing(true)
        sender.isSelected = !sender.isSelected
        actionButton.setTitle(sender.isSelected ? "登录" : "下一步", for: .normal)
        let loginView = sender.isSelected ? accountLoginView : phoneLoginView
        loginView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        actionButton.isEnabled = loginView.isEnableAction
        UIView.animate(withDuration: 0.2, animations: {[weak self] in
            loginView.transform = .identity
            self?.currentLoginView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        })
        currentLoginView = loginView
    }
    
    @objc private func nextStep() {
        if let delegate = UIApplication.shared.delegate,let window = delegate.window {
            window?.rootViewController?.dismiss(animated: true, completion: nil)
            window?.rootViewController = XHTabBarController()
        }
    }
    
    @objc private func finePassword() {
        
    }
    
    @objc private func moreOptions() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
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
        
        private lazy var areaButton: UIButton = {
            let temp = UIButton(type: .custom)
            addSubview(temp)
            temp.translatesAutoresizingMaskIntoConstraints = false
            temp.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            temp.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            temp.heightAnchor.constraint(equalToConstant: 44).isActive = true
            temp.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true
            temp.setImage(#imageLiteral(resourceName: "Card_ArrowGrey"), for: .normal)
            temp.contentHorizontalAlignment = .right
            temp.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: edgeMargin * 2)
            temp.addTarget(self, action: #selector(selectArea), for: .touchUpInside)
            return temp
        }()
        
        private lazy var areaTipLabel: UILabel = {
            let temp = addLabel()
            temp.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin * 2).isActive = true
            temp.centerYAnchor.constraint(equalTo: areaButton.centerYAnchor).isActive = true
            temp.text = "国家/地区"
            return temp
        }()
        
        private lazy var areaNameLabel: UILabel = {
            let temp = addLabel()
            temp.leftAnchor.constraint(equalTo: areaTipLabel.rightAnchor, constant: edgeMargin * 2).isActive = true
            temp.centerYAnchor.constraint(equalTo: areaTipLabel.centerYAnchor).isActive = true
            temp.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -edgeMargin * 2).isActive = true
            temp.adjustsFontSizeToFitWidth = true
            return temp
        }()
        
        private lazy var areaCodeTF: UITextField = {
            let temp = addTextField()
            temp.leftAnchor.constraint(equalTo: areaTipLabel.leftAnchor).isActive = true
            temp.rightAnchor.constraint(equalTo: areaTipLabel.rightAnchor, constant: 10).isActive = true
            temp.heightAnchor.constraint(equalToConstant: 44).isActive = true
            temp.topAnchor.constraint(equalTo: areaButton.bottomAnchor).isActive = true
            temp.delegate = self
            temp.addTarget(self, action: #selector(areaCodeDidChange(_:)), for: .editingChanged)
            return temp
        }()
        
        private lazy var phoneTF: UITextField = {
            let temp = addTextField()
            temp.leftAnchor.constraint(equalTo: areaCodeTF.rightAnchor, constant: 10.5).isActive = true
            temp.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeMargin * 2).isActive = true
            temp.topAnchor.constraint(equalTo: areaCodeTF.topAnchor).isActive = true
            temp.bottomAnchor.constraint(equalTo: areaCodeTF.bottomAnchor).isActive = true
            return temp
        }()
        
        private lazy var accountTF: UITextField = {
            let temp = addTextField(.default)
            temp.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeMargin * 2).isActive = true
            temp.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50).isActive = true
            temp.heightAnchor.constraint(equalToConstant: 44).isActive = true
            temp.placeholder = "微信号/QQ号/邮箱"
            return temp
        }()
        
        private lazy var passwordTF: UITextField = {
            let temp = addTextField(.asciiCapable)
            temp.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeMargin * 2).isActive = true
            temp.topAnchor.constraint(equalTo: accountTF.bottomAnchor).isActive = true
            temp.heightAnchor.constraint(equalToConstant: 44).isActive = true
            temp.leftAnchor.constraint(equalTo: accountTF.leftAnchor).isActive = true
            temp.placeholder = "请填写密码"
            return temp
        }()
        
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
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin * 2).isActive = true
            titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            titleLabel.font = UIFont.systemFont(ofSize: 25)
            switch style {
            case .phone:
                titleLabel.text = "手机号登录"
                addLine().bottomAnchor.constraint(equalTo: areaButton.bottomAnchor).isActive = true
                areaNameLabel.text = "中国"
                areaCodeTF.text = "+86"
                let vLine = UIView()
                addSubview(vLine)
                vLine.translatesAutoresizingMaskIntoConstraints = false
                vLine.leftAnchor.constraint(equalTo: areaCodeTF.rightAnchor).isActive = true
                vLine.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
                vLine.heightAnchor.constraint(equalTo: areaCodeTF.heightAnchor).isActive = true
                vLine.topAnchor.constraint(equalTo: areaCodeTF.topAnchor).isActive = true
                vLine.backgroundColor = UIColor.separatorLine
                addLine().bottomAnchor.constraint(equalTo: areaCodeTF.bottomAnchor).isActive = true
                phoneTF.placeholder = "请填写手机号码"
                phoneTF.addTarget(self, action: #selector(phoneNumDidChange(_:)), for: .editingChanged)
                areaCodeTF.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            case .other:
                titleLabel.text = "微信号/QQ号/邮箱登录"
                let topLable = addLabel()
                topLable.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin * 2).isActive = true
                topLable.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25).isActive = true
                topLable.centerYAnchor.constraint(equalTo: accountTF.centerYAnchor).isActive = true
                addLine().bottomAnchor.constraint(equalTo: accountTF.bottomAnchor).isActive = true
                accountTF.leftAnchor.constraint(equalTo: topLable.rightAnchor).isActive = true
                topLable.text = "账号"
                let bottomLabel = addLabel()
                bottomLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin * 2).isActive = true
                bottomLabel.widthAnchor.constraint(equalTo: topLable.widthAnchor).isActive = true
                bottomLabel.centerYAnchor.constraint(equalTo: passwordTF.centerYAnchor).isActive = true
                bottomLabel.text = "密码"
                addLine().bottomAnchor.constraint(equalTo: passwordTF.bottomAnchor).isActive = true
                passwordTF.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                passwordTF.isSecureTextEntry = true
            }
            
        }
        
        private func addLine() -> UIView {
            let line = UIView()
            addSubview(line)
            line.translatesAutoresizingMaskIntoConstraints = false
            line.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin * 2).isActive = true
            line.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeMargin * 2).isActive = true
            line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            line.backgroundColor = UIColor.separatorLine
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
        
        private func addTextField(_ keyboadType: UIKeyboardType = .numberPad) -> UITextField {
            let textField = UITextField()
            addSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.textColor = UIColor.black
            textField.font = UIFont.systemFont(ofSize: 20)
            textField.tintColor = UIColor.main
            textField.keyboardType = keyboadType
            return textField
        }
        
        @objc private func areaCodeDidChange(_ sender: UITextField) {
            var code: String = "+"
            if let text = sender.text {
                code = text
            }
            if !code.hasPrefix("+") {
                code = "+" + code
            }
            sender.text = code
            if code == "+" {
                areaNameLabel.text = "从列表中选择"
            } else if let area = XHArea(code) {
                areaNameLabel.text = area.name
            } else {
                areaNameLabel.text = "国家/地区代码无效"
            }
        }
        
        @objc private func selectArea() {
            let nav = XHBlackNavigationController(rootViewController: XHAreaViewController())
            viewController?.navigationController?.present(nav, animated: true, completion: nil)
        }
        
        @objc private func phoneNumDidChange(_ sender: UITextField) {
            guard let text = sender.text?.substringMatchRule("\\d", options: .anchorsMatchLines) else { return }
            sender.text = text
            if let viewController = self.viewController as? XHLoginViewController {
                viewController.actionButton.isEnabled = !text.isEmpty
            }
        }
        
        var isEnableAction: Bool {
            if style == .phone {
                if let text = phoneTF.text {
                    return !text.isEmpty
                }
            }
            return false
        }
        
        func setArea(_ area: XHArea) {
            areaNameLabel.text = area.name
            areaCodeTF.text = "+" + area.areaCode
            /// 如果为中国地区，对电话号码进行格式化操作
        }
    }

}

extension XHLoginViewController.XHLoginView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty,let text = textField.text,text == "+" {
            return false
        }
        var markLength = range.length
        if range.location == 0 {
            markLength -= 1
        }
        if !string.isEmpty,let text = textField.text,text.count + string.count - markLength > 5 {
            return false
        }
        return true
    }
    
}

extension String {
    
    func matchRule(_ rule: String) -> Bool {
        let predicate = NSPredicate(format: "self  matches %@", rule)
        return predicate.evaluate(with: self)
    }
    
    func substringMatchRule(_ rule: String,options: NSRegularExpression.Options) -> String? {
        do {
            let regular = try NSRegularExpression(pattern: rule, options: options)
            let resultArr = regular.matches(in: self, options: .reportProgress, range: NSMakeRange(0, count))
            let arr = resultArr.map { (result) -> String in
                let range = result.range
                let string = (self as NSString).substring(with: range) as String
                return string
            }
            return arr.joined()
        } catch {
            return nil
        }
    }
    
}

extension UIView {
    
    var viewController: UIViewController? {
        var responder = next
        while responder != nil {
            if let temp = responder as? UIViewController {
                return temp
            }
            responder = responder?.next
        }
        return nil
    }
}
