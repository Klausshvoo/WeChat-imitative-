//
//  XHMessageCell.swift
//  WeChat
//
//  Created by Li on 2018/7/28.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHMessageCell: UITableViewCell {
    
    fileprivate let avatarView = UIImageView(image: #imageLiteral(resourceName: "DefaultHead"))
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.background
        selectionStyle = .none
        contentView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor).isActive = true
        avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        avatarView.layer.cornerRadius = 5
        avatarView.layer.masksToBounds = true
        if let reuseIdentifier = reuseIdentifier,reuseIdentifier.hasSuffix("To") {
            avatarView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        } else {
            avatarView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var message: XHMessage! {
        didSet {
            // 设置头像
        }
    }
    
}

fileprivate class XHMessageBubbleiew: UIImageView {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    weak var delegate: XHMessageBubbleiewDelegate?
    
    override var image: UIImage? {
        set {
            super.image = newValue?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 15, bottom: 20, right: 15), resizingMode: .stretch)
        }
        get {
            return super.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.bubbleViewDidLongPressDown(self)
        } else if sender.state == .ended {
            delegate?.bubbleViewDidLongPressUp(self)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 54)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return performAction(action)
    }
    
    /// 复制，只存在于文本消息
    override func copyItem(_ sender: UIMenuController) {
        if let message = sender.message as? XHTextMessage {
            UIPasteboard.general.string = message.content
        }
    }
    
    /// 转发（当前ViewController必须遵循消息转发协议）
    override func transpondItem(_ sender: UIMenuController) {
        if let message = sender.message,let viewController = self.viewController as? XHMessageTranspondable {
            viewController.transpond(message)
        }
    }
    
    /// 收藏
    override func collectItem(_ sender: UIMenuController) {
        
    }
    
    /// 删除
    override func deleteItem(_ sender: UIMenuController) {
        
    }
    
    /// 撤回
    override func roolbackItem(_ sender: UIMenuController) {
        
    }
    
    /// 提醒
    override func remindItem(_ sender: UIMenuController) {
        
    }
    
    /// 多选
    override func mutableItem(_ sender: UIMenuController) {
        
    }
    
    /// 听筒播放
    override func earpiecePlayItem(_ sender: UIMenuController) {
        if let message = sender.message as? XHAudioMessage {
            delegate?.bunnleView(self, shouldEarpiecePlayAudio: message)
        }
    }
    
}

fileprivate protocol XHMessageBubbleiewDelegate: NSObjectProtocol {
    
    func bubbleViewDidLongPressDown(_ bubbleView: XHMessageBubbleiew)
    
    func bubbleViewDidLongPressUp(_ bubbleView: XHMessageBubbleiew)
    
    func bunnleView(_ bubbleView: XHMessageBubbleiew,shouldEarpiecePlayAudio message:XHAudioMessage)
    
}

class XHMessageBubbleCell: XHMessageCell,XHMessageBubbleiewDelegate {
    
    fileprivate let bubbleView = XHMessageBubbleiew(frame: .zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bubbleView)
        bubbleView.delegate = self
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        if let reuseIdentifier = reuseIdentifier,reuseIdentifier.hasSuffix("To") {
            bubbleView.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 5).isActive = true
            bubbleView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -70).isActive = true
            bubbleView.image = #imageLiteral(resourceName: "ReceiverTextNodeBkg")
        } else {
            bubbleView.rightAnchor.constraint(equalTo: avatarView.leftAnchor, constant: -5).isActive = true
            bubbleView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: 70).isActive = true
            bubbleView.image = #imageLiteral(resourceName: "SenderTextNodeBkg")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func bubbleViewDidLongPressDown(_ bubbleView: XHMessageBubbleiew) {}
    
    fileprivate func bubbleViewDidLongPressUp(_ bubbleView: XHMessageBubbleiew) {}
    
    fileprivate func bunnleView(_ bubbleView: XHMessageBubbleiew, shouldEarpiecePlayAudio message: XHAudioMessage) {}
    
}

class XHTextMessageCell: XHMessageBubbleCell {
    
    private let contentLabel = XHLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleView.addSubview(contentLabel)
        contentLabel.lineSpacing = 3
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        contentLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -20).isActive = true
        contentLabel.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 20).isActive = true
        contentLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 163
        contentLabel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var message: XHMessage! {
        didSet {
            if let message = message as? XHTextMessage {
                contentLabel.text = message.content
            }
        }
    }
    
    fileprivate override func bubbleViewDidLongPressDown(_ bubbleView: XHMessageBubbleiew) {
        let menuController = bubbleView.showMenuController([.copy,.transpond,.collect,.delete,.remind,.mutable], targetRect: bubbleView.bounds, in: bubbleView)
        menuController.message = message
    }
    
}

extension XHTextMessageCell: XHLabelLinkDelegate {
    
    func label(_ label: XHLabel, didClickLink string: String, option: XHLabelLinkOption) {
        print("点击了电话:\(string)")
    }
}

class XHAudioMessageCell: XHMessageBubbleCell {
    
    private let audioImageView = UIImageView()
    
    private let durationLabel = UILabel()
    
    private var bubbleViewWidthConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(audioImageView)
        audioImageView.translatesAutoresizingMaskIntoConstraints = false
        audioImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
        addSubview(durationLabel)
        durationLabel.font = UIFont.systemFont(ofSize: 15)
        durationLabel.textColor = UIColor.grayText
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.topAnchor.constraint(equalTo: audioImageView.centerYAnchor).isActive = true
        var image: UIImage
        if let reuseIdentifier = reuseIdentifier,reuseIdentifier.hasSuffix("To") {
            image = #imageLiteral(resourceName: "ReceiverVoiceNodePlaying")
            audioImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 20).isActive = true
            durationLabel.leftAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
            audioImageView.animationImages = [#imageLiteral(resourceName: "ReceiverVoiceNodePlaying001"),#imageLiteral(resourceName: "ReceiverVoiceNodePlaying002"),#imageLiteral(resourceName: "ReceiverVoiceNodePlaying003")]
        } else {
            image = #imageLiteral(resourceName: "SenderVoiceNodePlaying")
            audioImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -20).isActive = true
            durationLabel.rightAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
            audioImageView.animationImages = [#imageLiteral(resourceName: "SenderVoiceNodePlaying001"),#imageLiteral(resourceName: "SenderVoiceNodePlaying002"),#imageLiteral(resourceName: "SenderVoiceNodePlaying003")]
        }
        audioImageView.animationDuration = 1
        audioImageView.image = image
        audioImageView.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
        audioImageView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        bubbleViewWidthConstraint = bubbleView.widthAnchor.constraint(equalToConstant: 60)
        bubbleViewWidthConstraint.isActive = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        bubbleView.addGestureRecognizer(tap)
        tap.require(toFail: bubbleView.longPressGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var message: XHMessage! {
        didSet {
            if let message = message as? XHAudioMessage {
                durationLabel.text = "\(Int(message.duration))″"
                bubbleViewWidthConstraint.constant = CGFloat(60 + message.duration * 3)
            }
        }
    }
    
    @objc private func handleTap() {
        if let message = self.message as? XHAudioMessage {
            let manager = XHAudioManager.shared
            if manager.canPlayBackWithSpeaker() {
                let device = UIDevice.current
                device.isProximityMonitoringEnabled = true
                play(message.path, isSpeakerOutput: true)
                // 每次点击都用扬声器播放，同时监测设备和耳朵之间的距离
                NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceProximityState), name: .UIDeviceProximityStateDidChange, object: nil)
            } else {
                play(message.path, isSpeakerOutput: false)
            }
        }
    }
    
    // MARK: - UIDeviceProximityStateDidChange
    @objc private func handleDeviceProximityState() {
        let manager = XHAudioManager.shared
        if manager.canPlayBackWithSpeaker() { //未插入耳机,则根据情况进行切换
            XHAudioManager.shared.replay(isSpeakerOutput: !UIDevice.current.proximityState)
        } else {// 已插入耳机，关闭距离监控
            closeProximityMonitoring()
        }
    }
    
    fileprivate override func bubbleViewDidLongPressDown(_ bubbleView: XHMessageBubbleiew) {
        let menuController = bubbleView.showMenuController([.earpiecePlay,.collect,.delete,.remind,.mutable], targetRect: bubbleView.bounds, in: bubbleView)
        menuController.message = message
    }
    
    fileprivate override func bunnleView(_ bubbleView: XHMessageBubbleiew, shouldEarpiecePlayAudio message: XHAudioMessage) {
        play(message.path, isSpeakerOutput: false)
    }
    
    private func play(_ path: String,isSpeakerOutput flag: Bool = true) {
        let manager = XHAudioManager.shared
        manager.playDelegate = self
        manager.play(path: path, isSpeakerOutput: flag)
        audioImageView.startAnimating()
    }
    
    private func closeProximityMonitoring() {
        let device = UIDevice.current
        guard device.isProximityMonitoringEnabled else { return }
        device.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self, name: .UIDeviceProximityStateDidChange, object: nil)
    }
    
    deinit {
        let manager = XHAudioManager.shared
        manager.stopPlaying()
        manager.stopRecording()
        closeProximityMonitoring()
    }
    
}

extension XHAudioMessageCell: XHAudioManagerPlayingDelegate {
    
    func audioManagerDidFinishPlaying(_ manager: XHAudioManager) {
        audioImageView.stopAnimating()
        closeProximityMonitoring()
    }
    
    func audioManager(_ manager: XHAudioManager, didOccur error: XHAudioPlayError) {
        audioImageView.stopAnimating()
        closeProximityMonitoring()
    }
    
}

fileprivate let menuItemTargetMessageKey = UnsafeRawPointer(bitPattern: "menuItemTargetMessageKey".hashValue)!

fileprivate extension UIMenuController {
    
    var message: XHMessage? {
        get {
            return objc_getAssociatedObject(self, menuItemTargetMessageKey) as? XHMessage
        }
        set {
            objc_setAssociatedObject(self, menuItemTargetMessageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
