//
//  AudioManager.swift
//  WeChat
//
//  Created by Li on 2018/7/25.
//  Copyright © 2018年 Li. All rights reserved.
//

import AVFoundation
import UIKit

class XHAudioManager: NSObject {
    
    static func requestAccess(completionHandler: @escaping (Bool) -> Void) {
        let status =  AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: completionHandler)
        }
    }
    
    static func checkAuthorizationStatus() -> Bool {
        let status =  AVCaptureDevice.authorizationStatus(for: .audio)
        guard status != .authorized else {
            return true
        }
        return false
    }
    
    static let shared = XHAudioManager()
    
    fileprivate var recorder: AVAudioRecorder? {
        didSet {
            if recorder == nil {
                removeNotifications()
            } else {
                addNotifications()
            }
        }
    }
    
    fileprivate var player: AVAudioPlayer? {
        didSet {
            if player == nil {
                removeNotifications()
            } else {
                addNotifications()
            }
        }
    }
    
    private var timer: Timer?
    
    weak var recordDelegate: XHAudioManagerRecordingDelegate?
    
    weak var playDelegate: XHAudioManagerPlayingDelegate?
    
    override init() {
        super.init()
        try? prepare()
    }
    
    private func prepare() throws {
        let fileManager = FileManager.default
        let path = NSHomeDirectory().appending("/Documents/Audio/")
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // MARK: - Notifications
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionDidInterrupt(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionDidRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    /// 音频被系统打断，则直接停止音频服务
    @objc private func audioSessionDidInterrupt(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        guard let type = info[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType,type == .began else { return }
        if let recorder = self.recorder,recorder.isRecording {
            cancelRecording()
            return;
        }
        if let player = self.player,player.isPlaying {
            stopPlaying()
        }
    }
    
    /// 插拔耳机中断音频，若为播放，则在暂停之后重播，若为录制，则取消录制
    @objc private func audioSessionDidRouteChange(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            if self?.recorder != nil {
                self?.cancelRecording()
            } else {
                guard let info = notification.userInfo else { return }
                guard let reason = info[AVAudioSessionRouteChangeReasonKey] as? AVAudioSession.RouteChangeReason else { return }
                switch reason {
                case .newDeviceAvailable:
                    if AVAudioSession.sharedInstance().category == .playback {
                       self?.replay(isSpeakerOutput: false)
                    }
                case .oldDeviceUnavailable:
                    if AVAudioSession.sharedInstance().category == .playAndRecord {
                        self?.replay(isSpeakerOutput: true)
                    }
                default:
                    break
                }
            }
            
        }
    }
    
    // MARK: - Play & Record
    /// 开始播放音频，若正在播放，取消正在播放;若正在录制，取消录制
    func play(path: String,isSpeakerOutput flag: Bool = true) {
        cancelRecording()
        stopPlaying()
        var aError: XHAudioPlayError?
        do {
            
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: <#T##AVAudioSession.CategoryOptions#>)
//            try AVAudioSession.sharedInstance().setCategory(flag ? convertFromAVAudioSessionCategory(AVAudioSession.Category.playback) : convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord))
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            aError = .noDevice
        }
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
        } catch {
            aError = .noFile
        }
        if let error = aError {
            playDelegate?.audioManager(self, didOccur: error)
        } else {
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
        }
    }
    
    /// 监测是否可以用扬声器播放（有没有插耳机）
    func canPlayBackWithSpeaker() -> Bool {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        let filter = outputs.filter({ $0.portType == .headphones })
        return filter.count == 0
    }
    
    /// 重播
    func replay(isSpeakerOutput flag: Bool) {
        guard let player = player else { return }
        do {
//            try AVAudioSession.sharedInstance().category
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            playDelegate?.audioManager(self, didOccur: .noDevice)
        }
        player.currentTime = 0
    }
    
    func stopPlaying() {
        guard let player = player,player.isPlaying else { return }
        player.stop()
        playDelegate?.audioManager(self, didOccur: .interrupt)
        self.player = nil
    }
    
    /// 录制开始将会停止播放，若正在录制，该方法无效
    func record(at path: String) {
        stopPlaying()
        guard recorder == nil else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            recordDelegate?.audioManager(self, didOccur: .noDevice)
            return
        }
        do {
            recorder = try AVAudioRecorder(url: URL(fileURLWithPath: path), settings: [AVSampleRateKey: NSNumber(value: 8000),AVFormatIDKey: kAudioFormatLinearPCM,AVLinearPCMBitDepthKey: NSNumber(value: 16),AVNumberOfChannelsKey: NSNumber(value: 1)])
        } catch {
            recordDelegate?.audioManager(self, didOccur: .noFile)
            return
        }
        recorder?.delegate = self
        recorder?.prepareToRecord()
        timer = Timer(timeInterval: 0.2, target: self, selector: #selector(onRecording), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        recorder?.isMeteringEnabled = true
        recorder?.record()
    }
    
    @objc private func onRecording() {
        if let recorder = self.recorder {
            recorder.updateMeters()
            let temp = recorder.peakPower(forChannel: 0)
            var volume: Float = 0
            if temp > -15 {
                volume = 1
            } else if temp < -35 {
                volume = 0
            } else {
                volume = (temp + 35) / 20
            }
            recordDelegate?.audioManager(self, didRecordAt: volume)
        }
    }
    
    func stopRecording() {
        guard let recorder = self.recorder,recorder.isRecording else { return }
        let duration = recorder.currentTime
        recorder.stop()
        if duration < 1 {
            recorder.deleteRecording()
            recordDelegate?.audioManager(self, didOccur: .tooShort)
        } else {
            var path = recorder.url.absoluteString
            path = path.replacingOccurrences(of: "file://", with: "")
            recordDelegate?.audioManager(self, didEndRecordingAt: path, duration: duration)
        }
        self.recorder = nil
    }
    
    func creatRecordPath() -> String {
        let date = Date().stringValue("yyyyMMddHHmmsss")
        return NSHomeDirectory().appending("/Documents/Audio/\(date).caf")
    }
    
    func cancelRecording(_ error: XHAudioRecordError = .cancel) {
        guard let recorder = self.recorder,recorder.isRecording else { return }
        recorder.stop()
        recorder.deleteRecording()
        recordDelegate?.audioManager(self, didOccur: error)
        self.recorder = nil
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension XHAudioManager: AVAudioRecorderDelegate {
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        cancelRecording(.encodeError)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - AVAudioPlayerDelegate
extension XHAudioManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playDelegate?.audioManagerDidFinishPlaying(self)
        self.player = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        playDelegate?.audioManager(self, didOccur: .decodeError)
    }
    
}

// MARK: - UIAlertController+RecordAuthorization
extension UIAlertController {
    
    static func alertForAudioNotAuthorized() -> UIAlertController {
        let alert = UIAlertController(title: "无法录音", message: "请在iPhone的\"设置-隐私-麦克风\"选项中，允许微信访问你的手机麦克风", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        return alert;
    }
    
}

// MARK: - XHAudioManagerRecordingDelegate
enum XHAudioRecordError: Error {
    
    /// 录制编码错误
    case encodeError
    
    /// 文件创建失败
    case noFile
    
    /// 无法初始化设备
    case noDevice
    
    /// 录制时间少于1秒
    case tooShort
    
    /// 被取消
    case cancel
}

protocol XHAudioManagerRecordingDelegate: NSObjectProtocol {
    
    func audioManager(_ manager: XHAudioManager,didRecordAt volume: Float)
    
    func audioManager(_ manager: XHAudioManager,didEndRecordingAt path: String,duration: TimeInterval)
    
    func audioManager(_ manager: XHAudioManager,didOccur error: XHAudioRecordError)
    
}

// MARK: - XHAudioManagerPlayingDelegate
enum XHAudioPlayError: Error {
    
    /// 解码错误
    case decodeError
    
    /// 文件不存在
    case noFile
    
    /// 无法初始化设备
    case noDevice
    
    /// 被打断
    case interrupt
    
}

protocol XHAudioManagerPlayingDelegate: NSObjectProtocol {
    
    func audioManagerDidFinishPlaying(_ manager: XHAudioManager)
    
    func audioManager(_ manager: XHAudioManager,didOccur error: XHAudioPlayError)
    
}
