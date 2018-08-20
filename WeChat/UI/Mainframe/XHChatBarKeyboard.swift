//
//  XHChatBarKeyboard.swift
//  WeChat
//
//  Created by Li on 2018/7/25.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHChatBarKeyboard: UIView {
    
    fileprivate let colletionView: UICollectionView!
    
    fileprivate let pageControl = UIPageControl()
    
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    
    override init(frame: CGRect) {
        flowLayout.scrollDirection = .horizontal
        colletionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        super.init(frame: frame)
        addSubview(colletionView)
        colletionView.isPagingEnabled = true
        colletionView.backgroundColor = UIColor.clear
        colletionView.translatesAutoresizingMaskIntoConstraints = false
        colletionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colletionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        colletionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colletionView.heightAnchor.constraint(equalToConstant: 165).isActive = true
        colletionView.showsHorizontalScrollIndicator = false
        addSubview(pageControl)
        colletionView.dataSource = self
        colletionView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension XHChatBarKeyboard: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
    
}

extension XHChatBarKeyboard: UICollectionViewDelegate {}

class XHChatBarExpressionKeyboard: XHChatBarKeyboard {
    
    weak var delegate: XHChatBarExpressionKeyboardDelegate?
    
    private lazy var emotionBags : [XHEmotionBag] = {
        var temp = [XHEmotionBag]()
        temp.append(XHEmotionBag.defaultBag)
        return temp
    }()
    
    private var selectIndex: Int = 0
    
    private var scrollView = UIScrollView(frame: .zero)
    
    override init(frame: CGRect) {
        var height: CGFloat = 219
        if UIScreen.main.bounds.height == 812 {
            height = 253
        }
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        flowLayout.itemSize = CGSize(width: 30, height: 30)
        flowLayout.minimumLineSpacing = (UIScreen.main.bounds.width - 9 * 30 - 40) / 8
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 15, right: 20)
        colletionView.register(XHExpressionCell.self, forCellWithReuseIdentifier: "cell")
        let addButton = UIButton(type: .custom)
        addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.leftAnchor.constraint(equalTo: leftAnchor).isActive  = true
        addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        addButton.widthAnchor.constraint(equalTo: addButton.heightAnchor).isActive = true
        addButton.setImage(#imageLiteral(resourceName: "EmotionsBagAdd"), for: .normal)
        addButton.backgroundColor = UIColor.white
        addButton.addTarget(self, action: #selector(shouldAddEmotionBag), for: .touchUpInside)
        addSubview(scrollView)
        scrollView.alwaysBounceHorizontal = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: addButton.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.backgroundColor = UIColor.white
        pageControl.numberOfPages = 5
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pageControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 10).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        configureEmotionsBags()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func shouldAddEmotionBag() {
        delegate?.keyboardShouldAddEmotionBag(self)
    }
    
    private func configureEmotionsBags() {
        var lastView: UIButton!
        for index in 0 ..< emotionBags.count {
            let bag = emotionBags[index]
            let button = UIButton(type: .custom)
            scrollView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            if let _ = bag.imageUrl {
                //                加载网络图片
            } else {
                button.setImage(#imageLiteral(resourceName: "EmotionsEmoji"), for: .normal)
                button.setImage(#imageLiteral(resourceName: "EmotionsEmoji"), for: .highlighted)
            }
            button.setBackgroundImage(UIImage(color: .white), for: .normal)
            button.setBackgroundImage(UIImage(color: UIColor(hex: 0xd2d5da)), for: .selected)
            if lastView == nil {
                button.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
            } else {
                button.leftAnchor.constraint(equalTo: lastView.rightAnchor, constant: 1).isActive = true
            }
            lastView  = button
            button.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            button.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            button.tag = index
            button.addTarget(self, action: #selector(selectEmotionBag(_:)), for: .touchUpInside)
            if index == selectIndex {
                button.isSelected = true
            }
        }
        lastView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 44).isActive  = true
    }
    
    @objc private func selectEmotionBag(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        sender.isSelected = !sender.isSelected
        selectIndex = sender.tag
        colletionView.reloadData()
    }
    
    private func getNumbersOfEmotionInSection() -> Int {
        return selectIndex == 0 ? 27 : 10
    }
    
    private func getEmotionItem(at indexPath: IndexPath) -> XHEmotion {
        let number = getNumbersOfEmotionInSection()
        let line = selectIndex == 0 ? 3 : 2
        let count = selectIndex == 0 ? 9 : 5
        let index = indexPath.section * number + (indexPath.item % line) * count + (indexPath.item / line)
        let bag = emotionBags[selectIndex]
        if bag.emotions.count > index {
            return emotionBags[selectIndex].emotions[index]
        }
        return .spaceItem
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let colletion = emotionBags[selectIndex]
        let number = getNumbersOfEmotionInSection()
        let count = (colletion.emotions.count + number - 1) / number
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getNumbersOfEmotionInSection()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XHExpressionCell
        cell.setEmotion(getEmotionItem(at: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emotion = getEmotionItem(at: indexPath)
        if selectIndex == 0 {
            delegate?.keyboard(self, shouldEnter: emotion)
        } else {
            delegate?.keyboard(self, shouldSend: emotion)
        }
    }
    
    class XHExpressionCell: UICollectionViewCell {
        
        private let imageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(imageView)
            imageView.frame = bounds
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setEmotion(_ emotion: XHEmotion) {
            if let imageName = emotion.imageName {
                imageView.image = UIImage(named: imageName)
            } else {
                imageView.image = nil
            }
        }
        
    }
    
}

extension String {
    /// 检测聊天表情，[微笑]
    var isExpression: Bool {
        let arr = ["[微笑]"]
        return arr.contains(self)
    }
    
}

struct XHEmotion: Codable {
    
    var title: String?
    
    var imageName: String?
    
    var imageUrl: String?
    
    static let spaceItem = XHEmotion()
    
    static let deleteItem = XHEmotion(title: "", imageName: "DeleteEmoticonBtn", imageUrl: nil)
    
}

class XHEmotionBag: NSObject,Codable {
    
    var imageUrl: String?
    
    var title: String?
    
    var emotions: [XHEmotion]!
    
    static let defaultBag: XHEmotionBag = {
        let temp = XHEmotionBag()
        var emotions = [XHEmotion]()
        let path = Bundle.main.path(forResource: "Emotions", ofType: "plist")!
        let arr = NSArray(contentsOfFile: path) as! [[String: String]]
        for index in 0 ..< arr.count {
            let dic = arr[index]
            var emotion = XHEmotion()
            emotion.title = dic["title"]
            emotion.imageName = dic["imageName"]
            emotions.append(emotion)
            if (index + 1) % 26 == 0 {
                emotions.append(.deleteItem)
            }
        }
        let rest = emotions.count % 27
        if rest > 0 {
            for _ in rest ..< 26 {
                emotions.append(.spaceItem)
            }
            emotions.append(.deleteItem)
        }
        temp.emotions = emotions
        return temp
    }()
    
}

protocol XHChatBarExpressionKeyboardDelegate: NSObjectProtocol {
    
    func keyboard(_ keyboard: XHChatBarExpressionKeyboard,shouldEnter emotion: XHEmotion)
    
    func keyboardShouldAddEmotionBag(_ keyboard: XHChatBarExpressionKeyboard)
    
    func keyboardShouldSend(_ keyboard: XHChatBarExpressionKeyboard)
    
    func keyboard(_ keyboard: XHChatBarExpressionKeyboard,shouldSend emotion: XHEmotion)
    
    func keyboardShouldSetEmotionBags(_ keyboard: XHChatBarExpressionKeyboard)
    
}

class XHChatBarMoreKeyboard: XHChatBarKeyboard {
    
    
    
}
