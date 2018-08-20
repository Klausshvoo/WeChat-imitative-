//
//  XHChatBar.swift
//  WeChat
//
//  Created by Li on 2018/7/18.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHChatBar: UIView {
    
    weak var delegate: XHChatBarDelegate?
    
    private let textView = XHChatBarTextView()
    
    private let audioButton = UIButton(type: .custom)
    
    private let expressionButton = XHChatBarButton(type: .custom)
    
    private let moreButton = XHChatBarButton(type: .custom)
    
    private let voiceButton = UIButton(type: .custom)
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private let recordStateView = XHRecordStateView()
    
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
        expressionButton.inputEmotionDelegate = self
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        textView.delegate = self
        textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.tintColor = UIColor.main
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.returnKeyType = .send
        textView.enablesReturnKeyAutomatically = true
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
        textView.textColor = UIColor.grayText
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
            let constant = max(textView.contentSize.height, 40)
            guard constant != textViewHeightConstraint.constant else { return }
            textViewHeightConstraint.constant = constant
            delegate?.chatBardidChangeContentSize(self)
        }
    }
    
    // MARK: - 语音和键盘切换
    @objc private func audioButtonClick(_ sender: UIButton) {
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
            if expressionButton.isSelected  {
                expressionButton.isSelected = false
                expressionButton.setImage(#imageLiteral(resourceName: "ToolViewEmotionHL"), for: .highlighted)
            } else if moreButton.isSelected {
                moreButton.isSelected = false
            }
            XHAudioManager.requestAccess { [weak self](flag) in
                if !flag {
                    self?.viewController?.present(UIAlertController.alertForAudioNotAuthorized(), animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - 语音
    @objc private func voiceButtonTouchDown(_ sender: UIButton) {
        // 检测权限，没有权限进行提示
        guard XHAudioManager.checkAuthorizationStatus() else {
            viewController?.present(UIAlertController.alertForAudioNotAuthorized(), animated: true, completion: nil)
            return;
        }
        if let viewController = viewController {
            viewController.view.addSubview(recordStateView)
            recordStateView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
            recordStateView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor).isActive = true
        }
        changeVoiceButtonTitle(for: .touchDown)
        sender.backgroundColor = UIColor.grayText
        let audioManager = XHAudioManager.shared
        audioManager.recordDelegate = self
        audioManager.record(at: audioManager.creatRecordPath())
        // 开启录音，若录制达到最大时长，主动调用touupinside
        perform(#selector(cancelVoiceButtonTouch), with: nil, afterDelay: maxRecordDuration)
    }
    
    @objc private func voiceButtonTouchDragInside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchDragInside)
        recordStateView.state = .normal
    }
    
    @objc private func voiceButtonTouchDragOutside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchDragOutside)
        recordStateView.state = .cancel
    }
    
    @objc private func voiceButtonTouchUpInside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchUpInside)
        sender.backgroundColor = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cancelVoiceButtonTouch), object: nil)
         XHAudioManager.shared.stopRecording()
    }
    
    @objc private func voiceButtonTouchUpOutside(_ sender: UIButton) {
        changeVoiceButtonTitle(for: .touchUpInside)
        sender.backgroundColor = nil
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cancelVoiceButtonTouch), object: nil)
        XHAudioManager.shared.cancelRecording()
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
        XHAudioManager.shared.stopRecording()
    }
    
    // MARK: - 表情和键盘切换
    @objc private func expressionButtonClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setImage(sender.isSelected ? #imageLiteral(resourceName: "ToolViewKeyboardHL") : #imageLiteral(resourceName: "ToolViewEmotionHL"), for: .highlighted)
        if sender.isSelected {
            sender.becomeFirstResponder()
            if audioButton.isSelected {
                audioButton.isSelected = false
                audioButton.setImage(#imageLiteral(resourceName: "ToolViewInputVoiceHL"), for: .highlighted)
                voiceButton.removeFromSuperview()
                configureTextView()
            } else if moreButton.isSelected {
                moreButton.isSelected = false
            }
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    // MARK: - 更多按钮响应键盘
    @objc private func moreButtomClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.becomeFirstResponder()
            if audioButton.isSelected {
                audioButton.isSelected = false
                audioButton.setImage(#imageLiteral(resourceName: "ToolViewInputVoiceHL"), for: .highlighted)
                voiceButton.removeFromSuperview()
                configureTextView()
            } else if expressionButton.isSelected {
                expressionButton.isSelected = false
                expressionButton.setImage(#imageLiteral(resourceName: "ToolViewEmotionHL"), for: .highlighted)
            }
        } else {
            textView.becomeFirstResponder()
        }
    }
    
}

extension XHChatBar: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if expressionButton.isSelected  {
            expressionButton.isSelected = false
            expressionButton.setImage(#imageLiteral(resourceName: "ToolViewEmotionHL"), for: .highlighted)
        } else if moreButton.isSelected {
            moreButton.isSelected = false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n" else { // 发送
            delegate?.chatBar(self, shouldSend: XHTextMessage(content: textView.text))
            textView.text = nil
            return false
        }
        if text == "" && range.length == 1 { //删除，检测表情进行整体删除
            let deleteText = (textView.text as NSString).substring(with: range)
            if deleteText == "]" {
                let begin = (textView.text as NSString).range(of: "[", options: .backwards).location
                if begin != NSNotFound {
                    let shouldDeleteRange = NSMakeRange(begin, range.location - begin + 1)
                    let shouldDeleteText = (textView.text as NSString).substring(with: shouldDeleteRange)
                    if shouldDeleteText.isExpression {
                        textView.text  = (textView.text as NSString).replacingCharacters(in: shouldDeleteRange, with: "")
                        return false
                    }
                }
            }
        }
        return true
    }
    
}

extension XHChatBar: XHChatBarExpressionKeyboardDelegate {
    
    func keyboard(_ keyboard: XHChatBarExpressionKeyboard, shouldEnter emotion: XHEmotion) {
        var text = textView.text ?? ""
        if let title = emotion.title,title.isEmpty {
            guard !text.isEmpty else { return }
            if textView(textView, shouldChangeTextIn: NSMakeRange(textView.text.count - 1, 1), replacementText: "") {
                text = String(text[text.startIndex ..< text.index(before: text.endIndex)])
                textView.text = text
            }
        } else {
            text += emotion.title!
            textView.text = text
        }
    }
    
    func keyboardShouldAddEmotionBag(_ keyboard: XHChatBarExpressionKeyboard) {
        delegate?.chatBar(self, shouldHandleAction: .addEmotionBag)
    }
    
    func keyboardShouldSend(_ keyboard: XHChatBarExpressionKeyboard) {
        delegate?.chatBar(self, shouldSend: XHTextMessage(content: textView.text))
    }
    
    func keyboard(_ keyboard: XHChatBarExpressionKeyboard, shouldSend emotion: XHEmotion) {
        delegate?.chatBar(self, shouldSend: XHEmotionMessage(emotion: emotion))
    }
    
    func keyboardShouldSetEmotionBags(_ keyboard: XHChatBarExpressionKeyboard) {
        delegate?.chatBar(self, shouldHandleAction: .setEmotionBags)
    }
    
}

// MARK: - XHAudioManagerRecordingDelegate
extension XHChatBar: XHAudioManagerRecordingDelegate {
    
    func audioManager(_ manager: XHAudioManager, didRecordAt volume: Float) {
        recordStateView.volume = volume
    }
    
    func audioManager(_ manager: XHAudioManager, didEndRecordingAt path: String, duration: TimeInterval) {
        recordStateView.removeFromSuperview()
        delegate?.chatBar(self, shouldSend: XHAudioMessage(path: path, duration: duration))
    }
    
    func audioManager(_ manager: XHAudioManager, didOccur error: XHAudioRecordError) {
        recordStateView.removeFromSuperview()
        if voiceButton.isTracking {
            voiceButton.cancelTracking(with: nil)
        }
        delegate?.chatBarDidCancelRecording(self)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action.description.hasSuffix("Item:") {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
}

enum XHChatBarKeyboardType: Int {
    case expression,more
}

fileprivate class XHChatBarButton: UIButton {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    weak var inputEmotionDelegate: XHChatBarExpressionKeyboardDelegate?
    
    var keyboardType: XHChatBarKeyboardType = .expression
    
    override var inputView: UIView? {
        switch keyboardType {
        case .expression:
            let keyboard = XHChatBarExpressionKeyboard()
            keyboard.delegate = self.inputEmotionDelegate
            return keyboard
        case .more:
            return XHChatBarMoreKeyboard()
        }
    }
    
}

fileprivate class XHChatBarTextView: UITextView {
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        textColor = UIColor.black
        return super.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        textColor = UIColor.grayText
        return super.resignFirstResponder()
    }
}

enum XHChatBarActionType: Int {
    case addEmotionBag,setEmotionBags,selectPhotoes,takePhoto,videoCall,location,redbag,transfer,speechInput,infoCard,collection,files,cards
}

protocol XHChatBarDelegate: NSObjectProtocol {
    
    func chatBar(_ chatBar: XHChatBar,shouldSend message: XHMessage)
    
    func chatBar(_ chatBar: XHChatBar,shouldHandleAction type: XHChatBarActionType)
    
    func chatBarDidBeginRecording(_ chatBar: XHChatBar)
    
    func chatBarDidCancelRecording(_ chatBar: XHChatBar)
    
    func chatBardidChangeContentSize(_ chatBar: XHChatBar)
    
}

