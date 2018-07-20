//
//  XHChatBar.swift
//  WeChat
//
//  Created by Li on 2018/7/18.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHChatBar: UIView {
    
    private let textView = UITextView()
    
    private let audioButton = UIButton(type: .custom)
    
    private let expressionButton = XHChatBarButton(type: .custom)
    
    private let moreButton = XHChatBarButton(type: .custom)
    
    private let voiceButton = UIButton(type: .custom)
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    /// 语音消息最长时间，
    var maxRecordDuration: TimeInterval = 60
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0xf5f5f5)
        addSubview(audioButton)
        audioButton.translatesAutoresizingMaskIntoConstraints = false
        let audioImage = #imageLiteral(resourceName: "ToolViewInputVoice")
        let width = audioImage.size.width
        audioButton.setImage(audioImage, for: .normal)
        audioButton.setImage(#imageLiteral(resourceName: "ToolViewInputVoiceHL"), for: .highlighted)
        audioButton.setImage(#imageLiteral(resourceName: "ToolViewKeyboard"), for: .selected)
        audioButton.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeMargin).isActive = true
        audioButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -edgeMargin).isActive  = true
        audioButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        audioButton.addTarget(self, action: #selector(audioButtonClick(_:)), for: .touchUpInside)
        addSubview(expressionButton)
        expressionButton.translatesAutoresizingMaskIntoConstraints = false
        expressionButton.setImage(#imageLiteral(resourceName: "ToolViewEmotion"), for: .normal)
        expressionButton.setImage(#imageLiteral(resourceName: "ToolViewEmotionHL"), for: .highlighted)
        expressionButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.setImage(#imageLiteral(resourceName: "TypeSelectorBtn_Black"), for: .normal)
        moreButton.setImage(#imageLiteral(resourceName: "TypeSelectorBtnHL_Black"), for: .highlighted)
        moreButton.bottomAnchor.constraint(equalTo: audioButton.bottomAnchor).isActive = true
        moreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -edgeMargin).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        moreButton.keyboardType = .more
        moreButton.addTarget(self, action: #selector(moreButtomClick(_:)), for: .touchUpInside)
        expressionButton.rightAnchor.constraint(equalTo: moreButton.leftAnchor, constant: -6).isActive = true
        expressionButton.bottomAnchor.constraint(equalTo: audioButton.bottomAnchor).isActive = true
        expressionButton.addTarget(self, action: #selector(expressionButtonClick(_:)), for: .touchUpInside)
        expressionButton.setImage(#imageLiteral(resourceName: "ToolViewKeyboard"), for: .selected)
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.delegate = self
        textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.tintColor = UIColor.main
        textView.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        voiceButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        voiceButton.layer.cornerRadius = 5
        voiceButton.layer.masksToBounds = true
        voiceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        voiceButton.setTitleColor(UIColor.black, for: .normal)
        voiceButton.setTitle("按住 说话", for: .normal)
        voiceButton.layer.borderColor = UIColor.grayText.cgColor
        voiceButton.layer.borderWidth = 1
        voiceButton.addTarget(self, action: #selector(voiceButtonTouchDown(_:)), for: .touchDown)
        voiceButton.addTarget(self, action: #selector(voiceButtonTouchUpInside(_:)), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(voiceButtonTouchDragOutside(_:)), for: .touchDragOutside)
        voiceButton.addTarget(self, action: #selector(voiceButtonTouchDragInside(_:)), for: .touchDragInside)
        voiceButton.addTarget(self, action: #selector(voiceButtonTouchUpOutside(_:)), for: .touchUpOutside)
        voiceButton.addTarget(self, action: #selector(voiceButtonTouchCancel(_:)), for: .touchCancel)
        configureTextView()
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 40)
        textViewHeightConstraint.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextView() {
        addSubview(textView)
        textView.leftAnchor.constraint(equalTo: audioButton.rightAnchor, constant: 6).isActive = true
        textView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: expressionButton.leftAnchor, constant: -6).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
    }
    
    private func configureVoiceButton() {
        addSubview(voiceButton)
        voiceButton.leftAnchor.constraint(equalTo: audioButton.rightAnchor, constant: 6).isActive = true
        voiceButton.rightAnchor.constraint(equalTo: expressionButton.leftAnchor, constant: -6).isActive = true
        voiceButton.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        voiceButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            textViewHeightConstraint.constant = max(textView.contentSize.height, 40)
        }
    }
    
    // MARK: - 语音和键盘切换
    @objc private func audioButtonClick(_ sender: UIButton) {
        if expressionButton.isSelected {
            expressionButton.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        sender.setImage(sender.isSelected ? #imageLiteral(resourceName: "ToolViewKeyboardHL") : #imageLiteral(resourceName: "ToolViewInputVoiceHL"), for: .highlighted)
        if !sender.isSelected {
            voiceButton.removeFromSuperview()
            configureTextView()
            textView.becomeFirstResponder()
        } else {
            endEditing(true)
            textView.removeFromSuperview()
            configureVoiceButton()
        }
    }
    
    // MARK: - 语音
    @objc private func voiceButtonTouchDown(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchDown)
        sender.backgroundColor = UIColor.grayText
        // 开启录音，若录制达到最大时长，主动调用touupinside
        perform(#selector(cancelVoiceButtonTouch), with: nil, afterDelay: maxRecordDuration)
    }
    
    @objc private func voiceButtonTouchDragInside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchDragInside)
    }
    
    @objc private func voiceButtonTouchDragOutside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchDragOutside)
    }
    
    @objc private func voiceButtonTouchUpInside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchUpInside)
        sender.backgroundColor = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cancelVoiceButtonTouch), object: nil)
        // 判断录音时长，过短提示，符合长度进行发送
    }
    
    @objc private func voiceButtonTouchUpOutside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchUpInside)
        sender.backgroundColor = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cancelVoiceButtonTouch), object: nil)
        // 取消发送
    }
    
    @objc private func voiceButtonTouchCancel(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchCancel)
        sender.backgroundColor = nil
    }
    
    private func changeVoiceButtonTitle(for events: UIControlEvents) {
        var title: String
        if events.contains(.touchDown)  || events.contains(.touchDragInside) {
            title = "松开 结束"
        } else if events.contains(.touchDragOutside) {
            title = "松开 取消"
        } else {
            title = "按住 说话"
        }
        if title != voiceButton.currentTitle {
            voiceButton.setTitle(title, for: .normal)
        }
    }
    
    @objc private func cancelVoiceButtonTouch() {
        guard voiceButton.isTracking else { return }
        voiceButton.cancelTracking(with: nil)
        /// 达到最大语音录制时长调用，此处需要发送语音消息
    }
    
    // MARK: - 表情和键盘切换
    @objc private func expressionButtonClick(_ sender: UIButton) {
        if audioButton.isSelected {
            audioButton.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        sender.setImage(sender.isSelected ? #imageLiteral(resourceName: "ToolViewKeyboardHL") : #imageLiteral(resourceName: "ToolViewEmotionHL"), for: .highlighted)
        sender.becomeFirstResponder()
    }
    
    // MARK: - 更多按钮响应键盘
    @objc private func moreButtomClick(_ sender: UIButton) {
        if audioButton.isSelected {
            audioButton.isSelected = false
        }
        if expressionButton.isSelected {
            expressionButton.isSelected = false
        }
        sender.becomeFirstResponder()
    }
    
}

extension XHChatBar: UITextViewDelegate {
    
}

enum XHChatBarKeyboardType: Int {
    case expression,more
}

fileprivate class XHChatBarButton: UIButton {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var keyboardType: XHChatBarKeyboardType = .expression
    
    override var inputView: UIView? {
        return XHChatBarKeyboard(type: keyboardType)
    }
    
}


class XHChatBarKeyboard: UIView {
    
    private(set) var type: XHChatBarKeyboardType
    
    private let scrollView = UIScrollView()
    
    init(type: XHChatBarKeyboardType) {
        self.type = type
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.backgroundColor = UIColor.red
        configureKeyboard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureKeyboard() {
        switch type {
        case .expression:
            scrollView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -40).isActive = true
        case .more:
            scrollView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -10).isActive = true
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        }
        
    }
    
}
