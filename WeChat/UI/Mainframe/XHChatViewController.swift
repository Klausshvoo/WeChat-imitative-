//
//  XHChatViewController.swift
//  WeChat
//
//  Created by Li on 2018/7/18.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHChatViewController: UIViewController {
    
    var messageCollection: XHMessageCollection!
    
    private let chatBar = XHChatBar()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var dataArr: [XHMessage] = []
    
    private(set) var isTop: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        configureNavigationBar()
        configureTabelView()
        configureChatBar()
        registerKeyboardNotifications()
    }
    
    // MARK: - NavigationBar
    private func configureNavigationBar() {
        title = messageCollection.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_more"), style: .plain, target: self, action: #selector(showChatInfo))
    }
    
    @objc private func showChatInfo() {
        
    }
    
    // MARK: - ChatBar
    private func configureChatBar() {
        view.addSubview(chatBar)
        chatBar.translatesAutoresizingMaskIntoConstraints = false
        chatBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        chatBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        chatBar.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        chatBar.delegate = self
        tableView.bottomAnchor.constraint(equalTo: chatBar.topAnchor).isActive = true
    }
    
    // MARK: - tableView
    private func configureTabelView() {
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.background
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(XHMessageHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.sectionHeaderHeight = 40
        tableView.register(XHTextMessageCell.self, forType: .text)
        tableView.register(XHAudioMessageCell.self, forType: .audio)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isTop = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
        super.viewWillDisappear(animated)
        isTop = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        removeKeyboardNotifications()
    }

}

extension XHChatViewController: XHKeyboardObserver {
    
    func keyboardWillShow(_ noti: Notification) {
        guard isTop else { return }
        if let info = noti.userInfo,let frame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            var y = frame.height
            if #available(iOS 11.0, *) {
                y -= view.safeAreaInsets.bottom
            }
            chatBar.transform = CGAffineTransform(translationX: 0, y: -y)
            var contentInset = tableView.contentInset
            contentInset.bottom = y
            tableView.contentInset = contentInset
            if dataArr.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: dataArr.count - 1, section: 0), at: .none, animated: false)
            }
        }
    }
    
    func keyboardWillHide(_ noti: Notification) {
        guard isTop else { return }
        chatBar.resume()
        chatBar.transform = .identity
        var contentInset = tableView.contentInset
        contentInset.bottom = 0
        tableView.contentInset = contentInset
    }
    
}

extension XHChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = dataArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: message.sourceMember == nil ? "\(message.type.title)From" : "\(message.type.title)To", for: indexPath) as! XHMessageCell
        cell.message = message
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! XHMessageHeader
        if let message = dataArr.first {
            header.setTitle(message.time)
        }
        return header
    }
    
}

extension XHChatViewController: UITableViewDelegate {}

extension XHChatViewController: XHChatBarDelegate {
    
    func chatBar(_ chatBar: XHChatBar, shouldSend message: XHMessage) {
        let indexPath = IndexPath(row: dataArr.count, section: 0)
        dataArr.append(message)
        tableView.update({[weak self] in
            if indexPath.row == 0 {
                let set = IndexSet(integer: 0)
                self?.tableView.insertSections(set, with: .none)
            }
            self?.tableView.insertRows(at: [indexPath], with: .none)
        }) { [weak self](finished) in
            self?.tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }
    }
    
    func chatBar(_ chatBar: XHChatBar, shouldHandleAction type: XHChatBarActionType) {
        switch type {
        case .photoLibrary:
            let imagePicker = XHImagePickerController()
            imagePicker.uiDelegate = self
            present(XHImagePickerController(), animated: true, completion: nil)
        default:
            break
        }
    }
    
    func chatBarDidBeginRecording(_ chatBar: XHChatBar) {
        // 预加载一个语音消息
    }
    
    func chatBarDidCancelRecording(_ chatBar: XHChatBar) {
        // 移除预加载的语音消息
    }
    
    func chatBardidChangeContentSize(_ chatBar: XHChatBar) {
        if dataArr.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: dataArr.count - 1, section: 0), at: .none, animated: false)
        }
    } 
    
}

extension XHChatViewController: XHMessageTranspondable {
    
    func presentedViewControllerForTranspond() -> UIViewController {
        return navigationController ?? self
    }
    
}

extension XHChatViewController: XHImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: XHImagePickerController, didFinishPickingMediaAssets assets: [XHPhotoAsset]) {
        
    }
    
}

fileprivate extension UITableView {
    
    func register(_ cellClass: AnyClass, forType type: XHMessageType) {
        register(cellClass, forCellReuseIdentifier: "\(type.title)To")
        register(cellClass, forCellReuseIdentifier: "\(type.title)From")
    }
    
}



