//
//  XHMainframeController.swift
//  WeChat
//
//  Created by Li on 2018/7/16.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHMainframeController: UITableViewController {
    
    private lazy var searchController = UISearchController(searchResultsController: UIViewController())
    
    private var dataArr: [XHMessageCollection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        dataArr = XHMessageCollection.defaultColletions()
        tableView.tableFooterView = UIView()
        tableView.register(XHCommunicationCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func configureNavigationBar() {
        title = "微信"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_add"), title: nil, target: self, action: #selector(showMenuItems(_:)))
    }
    
    @objc private func showMenuItems(_ sender: UIButton) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! XHCommunicationCell
        cell.messageColletion = dataArr[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let collection = dataArr[indexPath.row]
        switch collection.type {
        case .chat,.groupChat:
            let chatController = XHChatViewController()
            chatController.messageCollection = collection
            navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard tableView.tableHeaderView == nil else { return }
        let searchBar = searchController.searchBar
        searchBar.barTintColor = UIColor.cellHL
        searchBar.placeholder = "搜索"
        searchBar.searchBarStyle = .minimal
        tableView.backgroundColor = UIColor.background
        searchBar.tintColor = UIColor.main
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

class XHCommunicationCell: UITableViewCell {
    
    private let avatarView = UIImageView(image: #imageLiteral(resourceName: "DefaultHead"))
    
    private let nameLabel = UILabel()
    
    private let messageLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    private let undisturbedView = UIImageView()
    
    private let badgeView = XHBadgeView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: edgeMargin).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        avatarView.heightAnchor.constraint(equalTo: avatarView.widthAnchor).isActive = true
        avatarView.layer.cornerRadius = 5
        avatarView.layer.masksToBounds = true
        contentView.addSubview(nameLabel)
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -3).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 8).isActive = true
        contentView.addSubview(messageLabel)
        messageLabel.textColor = UIColor.grayText
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 3).isActive = true
        contentView.addSubview(timeLabel)
        timeLabel.textColor = UIColor.grayText
        timeLabel.font = UIFont.systemFont(ofSize: 15)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -edgeMargin).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(lessThanOrEqualTo: timeLabel.leftAnchor, constant: -5).isActive = true
        contentView.addSubview(undisturbedView)
        let image = #imageLiteral(resourceName: "chatNotPush")
        undisturbedView.image = image
        undisturbedView.translatesAutoresizingMaskIntoConstraints = false
        undisturbedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -edgeMargin).isActive = true
        undisturbedView.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor).isActive = true
        undisturbedView.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
        undisturbedView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
        undisturbedView.isHidden = true
        messageLabel.rightAnchor.constraint(lessThanOrEqualTo: undisturbedView.leftAnchor, constant: -3).isActive = true
        contentView.addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.centerXAnchor.constraint(equalTo: avatarView.rightAnchor, constant: -3).isActive = true
        badgeView.centerYAnchor.constraint(equalTo: avatarView.topAnchor, constant: 3).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var messageColletion: XHMessageCollection! {
        didSet {
            nameLabel.text = messageColletion.name
            if let tips = messageColletion.tips,let abstract = messageColletion.abstract {
                let attributedText = NSMutableAttributedString(string: tips + abstract)
                attributedText.addAttribute(.foregroundColor, value: UIColor(hex: 0xe54f4f), range: NSMakeRange(0, tips.count))
                messageLabel.attributedText = attributedText
            } else {
                messageLabel.text = messageColletion.abstract
            }
            timeLabel.text = messageColletion.time
            undisturbedView.isHidden = !messageColletion.isUndisturbed
            badgeView.isHidden = messageColletion.unreadCount == 0
            badgeView.badgeValue = messageColletion.type == .chat ? "\(messageColletion.unreadCount)" : ""
        }
    }
    
}
