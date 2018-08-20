//
//  XHRecordStateView.swift
//  WeChat
//
//  Created by Li on 2018/7/26.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

enum XHRecordState {
    case normal,cancel
}

class XHRecordStateView: UIView {
    
    private let background = UIImageView(image: #imageLiteral(resourceName: "RecordingBkg"))
    
    private let volumeView = UIImageView(image: #imageLiteral(resourceName: "RecordingSignal001"))
    
    private let cancelView = UIImageView(image: #imageLiteral(resourceName: "RecordCancel"))
    
    private let stateLabel = UILabel()
    
    var state: XHRecordState = .normal {
        didSet {
            guard state != oldValue else { return }
            switch state {
            case .normal:
                stateLabel.text = "手指上滑，取消发送"
                stateLabel.backgroundColor = UIColor.clear
                cancelView.isHidden = true
                background.isHidden = false
                volumeView.isHidden = false
            case .cancel:
                stateLabel.text = "松开手指，取消发送"
                stateLabel.backgroundColor = UIColor(hex: 0x9c3939)
                cancelView.isHidden = false
                background.isHidden = true
                volumeView.isHidden = true
            }
        }
    }
    
    /// 音量取值区间为0-1
    var volume: Float = 0 {
        didSet {
            guard volume != oldValue else { return }
            let temp = roundf(volume / 0.143) + 1
            volumeView.image = UIImage(named: "RecordingSignal00\(temp)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 150).isActive = true
        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = UIColor(hex: 0x757575)
        addSubview(background)
        addSubview(volumeView)
        addSubview(cancelView)
        addSubview(stateLabel)
        cancelView.isHidden = true
        background.translatesAutoresizingMaskIntoConstraints = false
        let backgroudImageSize = background.image!.size
        background.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        background.heightAnchor.constraint(equalToConstant: backgroudImageSize.height).isActive = true
        background.widthAnchor.constraint(equalToConstant: backgroudImageSize.width).isActive = true
        volumeView.translatesAutoresizingMaskIntoConstraints = false
        let volumeImageSize = volumeView.image!.size
        volumeView.bottomAnchor.constraint(equalTo: background.bottomAnchor).isActive = true
        volumeView.topAnchor.constraint(equalTo: background.topAnchor).isActive = true
        volumeView.leftAnchor.constraint(equalTo: background.rightAnchor).isActive = true
        volumeView.widthAnchor.constraint(equalToConstant: volumeImageSize.width).isActive = true
        let width = backgroudImageSize.width + volumeImageSize.width
        background.leftAnchor.constraint(equalTo: leftAnchor, constant: (150 - width) / 2).isActive = true
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        stateLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stateLabel.font = UIFont.systemFont(ofSize: 14)
        stateLabel.textColor = UIColor.white
        stateLabel.text = "手指上滑，取消发送"
        stateLabel.layer.cornerRadius = 5
        stateLabel.layer.masksToBounds = true
        cancelView.translatesAutoresizingMaskIntoConstraints = false
        cancelView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cancelView.topAnchor.constraint(equalTo: background.topAnchor).isActive = true
        let cancelSize = cancelView.image!.size
        cancelView.widthAnchor.constraint(equalToConstant: cancelSize.width).isActive = true
        cancelView.heightAnchor.constraint(equalToConstant: cancelSize.height).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        state = .normal
        volume = 0
    }
    
}
