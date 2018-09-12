//
//  XHChatBarKeyboard.swift
//  WeChat
//
//  Created by Li on 2018/7/25.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHChatBarKeyboard: UIView {
    
    weak var delegate: XHChatBarKeyboardDelegate?
    
    fileprivate let colletionView: UICollectionView!
    
    fileprivate let pageControl = UIPageControl()
    
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    
    fileprivate let collectionHeight = UIScreen.main.bounds.width * (0.24 + 0.096) + 20
    
    override init(frame: CGRect) {
        flowLayout.scrollDirection = .horizontal
        colletionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        let screenBounds = UIScreen.main.bounds
        var height: CGFloat = collectionHeight + 54
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.delegate!.window!!
            height += window.safeAreaInsets.bottom
        }
        super.init(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: height))
        backgroundColor = UIColor(hex: 0xf5f5f6)
        addSubview(colletionView)
        colletionView.isPagingEnabled = true
        colletionView.backgroundColor = UIColor.clear
        colletionView.translatesAutoresizingMaskIntoConstraints = false
        colletionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        colletionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        colletionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colletionView.showsHorizontalScrollIndicator = false
        addSubview(pageControl)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: 0x8b8b8b)
        pageControl.pageIndicatorTintColor = UIColor(hex: 0xd6d6d6)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pageControl.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 10).isActive = true
        pageControl.topAnchor.constraint(equalTo: colletionView.bottomAnchor).isActive = true
        colletionView.dataSource = self
        colletionView.delegate = self
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0xbdbdbd)
        addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.topAnchor.constraint(equalTo: topAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationShow() {
        transform = CGAffineTransform(translationX: 0, y: bounds.height)
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.transform = .identity
        }
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

protocol XHChatBarKeyboardDelegate: NSObjectProtocol {}

class XHChatBarExpressionKeyboard: XHChatBarKeyboard {
    
    static let shared = XHChatBarExpressionKeyboard()
    
    private weak var _delegate: XHChatBarExpressionKeyboardDelegate?
    
    override weak var delegate: XHChatBarKeyboardDelegate? {
        set {
            if let temp = newValue as? XHChatBarExpressionKeyboardDelegate {
                _delegate = temp
            } else {
                _delegate = nil
            }
        }
        get {
            return _delegate
        }
    }
    
    weak var associatedInputView: XHEmotionKeyboardAssociatedInputView? {
        didSet {
            if let lastView = oldValue {
                NotificationCenter.default.removeObserver(self, name: lastView.notificationName, object: lastView)
            }
            sendButton.isEnabled = false
            if let view = associatedInputView {
                NotificationCenter.default.addObserver(self, selector: #selector(associatedTextDidChange(_:)), name: view.notificationName, object: view)
                if let text = view.associatedText,!text.isEmpty {
                    sendButton.isEnabled = true
                }
            }
        }
    }
    
    @objc private func associatedTextDidChange(_ notification: Notification) {
        if let object = notification.object as? XHEmotionKeyboardAssociatedInputView,let text = object.associatedText {
            sendButton.isEnabled = !text.isEmpty
        }
    }
    
    private lazy var emotionBags : [XHEmotionBag] = {
        var temp = [XHEmotionBag]()
        temp.append(XHEmotionBag.defaultBag)
        temp.append(XHEmotionBag.customBag)
        return temp
    }()
    
    private var numberOfSections: Int = 0
    
    private var selectIndex: Int = 0
    
    private var bagsCollectionView: UICollectionView!
    
    private let sendButton = UIButton(type: .custom)
    
    private lazy var settingButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        flowLayout.minimumInteritemSpacing = 10
        let insetMargin = UIScreen.main.bounds.width * 0.048
        flowLayout.sectionInset = UIEdgeInsets(top: insetMargin, left: insetMargin, bottom: insetMargin, right: insetMargin)
        colletionView.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        colletionView.register(XHExpressionCell.self, forCellWithReuseIdentifier: "cell")
        colletionView.backgroundColor = UIColor(hex: 0xf6f6f8)
        pageControl.backgroundColor = UIColor(hex: 0xf6f6f8)
        let addButton = UIButton(type: .custom)
        addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.leftAnchor.constraint(equalTo: leftAnchor).isActive  = true
        addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        addButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor).isActive = true
        addButton.widthAnchor.constraint(equalTo: addButton.heightAnchor).isActive = true
        addButton.setImage(#imageLiteral(resourceName: "EmotionsBagAdd"), for: .normal)
        addButton.backgroundColor = UIColor.white
        addButton.addTarget(self, action: #selector(shouldAddEmotionBag), for: .touchUpInside)
        let bagsFlowLayout = UICollectionViewFlowLayout()
        bagsFlowLayout.scrollDirection = .horizontal
        bagsFlowLayout.itemSize = CGSize(width: 44, height: 44)
        bagsFlowLayout.minimumInteritemSpacing = 0.01
        bagsFlowLayout.minimumLineSpacing = 0
        bagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: bagsFlowLayout)
        addSubview(bagsCollectionView)
        bringSubview(toFront: addButton)
        bagsCollectionView.alwaysBounceHorizontal = true
        bagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        bagsCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bagsCollectionView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        bagsCollectionView.topAnchor.constraint(equalTo: addButton.topAnchor).isActive = true
        bagsCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bagsCollectionView.backgroundColor = UIColor.white
        bagsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 60)
        bagsCollectionView.dataSource = self
        bagsCollectionView.delegate = self
        bagsCollectionView.showsHorizontalScrollIndicator = false
        bagsCollectionView.register(XHEmotionBagCell.self, forCellWithReuseIdentifier: "bag")
        let selectedBag = emotionBags[selectIndex]
        selectedBag.isSelected = true
        pageControl.numberOfPages = selectedBag.numberOfSections
        pageControl.addTarget(self, action: #selector(didSelectPage(_:)), for: .valueChanged)
        bringSubview(toFront: pageControl)
        addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: addButton.topAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: addButton.heightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: bagsCollectionView.contentInset.right).isActive = true
        sendButton.setBackgroundImage(#imageLiteral(resourceName: "EmotionsSendBtnBlue"), for: .normal)
        sendButton.setBackgroundImage(#imageLiteral(resourceName: "EmotionsSendBtnBlueHL"), for: .disabled)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        sendButton.setTitle("发送", for: .normal)
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.setTitleColor(UIColor.black, for: .disabled)
        sendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        sendButton.addTarget(self, action: #selector(didClickSendButton), for: .touchUpInside)
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didClickSendButton() {
        _delegate?.keyboardShouldSend(self)
        associatedInputView?.clearText()
        sendButton.isEnabled = false
    }
    
    private func reloadData() {
        numberOfSections = 0
        for bag in emotionBags {
            bag.beginSection = numberOfSections
            numberOfSections += bag.numberOfSections
        }
        self.colletionView.reloadData()
        self.bagsCollectionView.reloadData()
    }
    
    @objc private func shouldAddEmotionBag() {
        _delegate?.keyboardShouldAddEmotionBag(self)
    }
    
    @objc private func didSelectPage(_ pageControl: UIPageControl) {
        let bag = emotionBags[selectIndex]
        let section = bag.beginSection + pageControl.currentPage
        colletionView.setContentOffset(CGPoint(x: CGFloat(section) * colletionView.bounds.width , y: 0), animated: true)
    }
    
    private func getEmotionItem(at indexPath: IndexPath) -> XHEmotion {
        let bag = getCurrentBag(from: indexPath.section)
        let index = (indexPath.row % bag.numberOfLines) * bag.numbersInLine + (indexPath.item / bag.numberOfLines) + (indexPath.section - bag.beginSection) * (bag.numberOfLines * bag.numbersInLine)
        if bag.emotions.count > index {
            return bag.emotions[index]
        }
        return .spaceItem
    }
    
    private func getCurrentBag(from section: Int) -> XHEmotionBag {
        var count: Int = 0
        for bag in emotionBags {
            count += bag.numberOfSections
            if count > section {
                return bag
            }
        }
        return emotionBags.last!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.colletionView {
            return self.numberOfSections
        }
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.colletionView {
            let bag = getCurrentBag(from: section)
            return bag.numberOfLines * bag.numbersInLine
        }
        return emotionBags.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.colletionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XHExpressionCell
            cell.setEmotion(getEmotionItem(at: indexPath))
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bag", for: indexPath) as! XHEmotionBagCell
        cell.setEmotionBag(emotionBags[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.colletionView {
            let emotion = getEmotionItem(at: indexPath)
            if selectIndex == 0 {
                _delegate?.keyboard(self, shouldEnter: emotion)
                if let associatedView = associatedInputView {
                    NotificationCenter.default.post(name: associatedView.notificationName, object: associatedView)
                }
            } else {
                _delegate?.keyboard(self, shouldSend: emotion)
            }
        } else {
            guard selectIndex != indexPath.row else { return }
            let bag = emotionBags[selectIndex]
            bag.isSelected = false
            let selectedBag = emotionBags[indexPath.row]
            selectedBag.isSelected = true
            selectIndex = indexPath.row
            pageControl.numberOfPages = selectedBag.numberOfSections
            pageControl.currentPage = 0
            collectionView.reloadData()
            self.colletionView.setContentOffset(CGPoint(x: CGFloat(selectedBag.beginSection) * self.colletionView.bounds.width, y: 0), animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == colletionView {
            let section = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            let bag = getCurrentBag(from: section)
            pageControl.currentPage = section - bag.beginSection
            let selectedBag = emotionBags[selectIndex]
            if selectedBag != bag {
                pageControl.numberOfPages = bag.numberOfSections;
                selectedBag.isSelected = false
                bag.isSelected = true
                selectIndex = emotionBags.index(of: bag)!
                bagsCollectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard collectionView == self.colletionView else { return }
        collectionView.isScrollEnabled = false
        if let cell = collectionView.cellForItem(at: indexPath) {
            let emotion = getEmotionItem(at: indexPath)
            guard emotion != XHEmotion.deleteItem && emotion != .spaceItem else { return }
            let rect = cell.convert(cell.bounds, to: self)
            let tipView = XHEmotionTipView.shared
            addSubview(tipView)
            tipView.translatesAutoresizingMaskIntoConstraints = false
            tipView.centerXAnchor.constraint(equalTo: leftAnchor, constant: rect.midX).isActive = true
            let type: XHEmotionTipType = selectIndex == 0 ? .default : .normal
            if type == .default {
                tipView.bottomAnchor.constraint(equalTo: topAnchor, constant: rect.maxY).isActive = true
            } else {
                tipView.bottomAnchor.constraint(equalTo: topAnchor, constant: rect.minY).isActive = true
            }
            tipView.highlightEmotion(emotion, for: type)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard collectionView == self.colletionView else { return }
        XHEmotionTipView.shared.removeFromSuperview()
        collectionView.isScrollEnabled = true
    }
    
    class XHExpressionCell: UICollectionViewCell {
        
        private let imageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
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
    
    class XHEmotionBagCell: UICollectionViewCell {
        
        private let imageView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setEmotionBag(_ bag: XHEmotionBag) {
            if let image = bag.image {
                imageView.image = image
            } else {
                
            }
            contentView.backgroundColor = bag.isSelected ? UIColor(hex: 0xf6f6f8) : UIColor.clear
        }
        
    }
    
    enum XHEmotionTipType {
        case `default`,normal
    }
    
    class XHEmotionTipView: UIView {
        
        static let shared = XHEmotionTipView()
        
        private let backImageView = UIImageView()
        
        private let emotionView = UIImageView()
        
        private let titleLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(backImageView)
            backImageView.translatesAutoresizingMaskIntoConstraints = false
            backImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            backImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            backImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            backImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            addSubview(emotionView)
            emotionView.translatesAutoresizingMaskIntoConstraints = false
            emotionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            emotionView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            emotionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            emotionView.heightAnchor.constraint(equalTo: emotionView.widthAnchor).isActive = true
            addSubview(titleLabel)
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            titleLabel.topAnchor.constraint(equalTo: emotionView.bottomAnchor, constant: 4).isActive = true
            titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 8).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func highlightEmotion(_ emotion: XHEmotion,for type: XHEmotionTipType) {
            switch type {
            case .default:
                backImageView.image = #imageLiteral(resourceName: "EmoticonTips")
                if let imageName = emotion.imageName {
                    emotionView.image = UIImage(named: imageName)
                }
            case .normal:
                backImageView.image = #imageLiteral(resourceName: "EmoticonBigTipsMiddle").resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 20, right: 5), resizingMode: .stretch)
            }
            
            if let title = emotion.title {
                var text = title
                if title.hasPrefix("[") {
                    text = (title as NSString).substring(with: NSMakeRange(1, title.count - 2))
                }
                titleLabel.text = text
            }
        }
        
        override func removeFromSuperview() {
            super.removeFromSuperview()
            titleLabel.text = nil
            emotionView.image = nil
            backImageView.image = nil
        }
    }
    
    class XHEmotionHighlightImageView: UIImageView {
        
        func setImage(_ image: UIImage,for type: XHEmotionTipType) {
            self.type = type
            self.image = image
        }
        
        private var type: XHEmotionTipType = .default
        
        
        override var intrinsicContentSize: CGSize {
            switch type {
            case .default:
                return super.intrinsicContentSize
            case .normal:
                return CGSize(width: 100, height: 120)
            }
        }
        
    }
    
}

extension XHChatBarExpressionKeyboard: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.colletionView {
            let bag = getCurrentBag(from: indexPath.section)
            let sectionInset = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
            let itemHeight = (collectionView.bounds.height - CGFloat(bag.numberOfLines - 1) * 10 - sectionInset.top - sectionInset.bottom) / CGFloat(bag.numberOfLines)
            return CGSize(width: itemHeight, height: itemHeight)
        }
        return CGSize(width: 44, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.colletionView {
            let bag = getCurrentBag(from: section)
            let sectionInset = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
            let itemHeight = (collectionView.bounds.height - CGFloat(bag.numberOfLines - 1) * 10 - sectionInset.top - sectionInset.bottom) / CGFloat(bag.numberOfLines)
            return (collectionView.bounds.width - sectionInset.left - sectionInset.bottom - itemHeight * CGFloat(bag.numbersInLine)) / CGFloat(bag.numbersInLine - 1)
        }
        return 0
    }
    
}

extension String {
    /// 检测聊天表情，[微笑]
    var isExpression: Bool {
        let arr = ["[微笑]"]
        return arr.contains(self)
    }
    
}

struct XHEmotion: Codable,Equatable {
    
    var title: String?
    
    var imageName: String?
    
    var imageUrl: String?
    
    static let spaceItem = XHEmotion()
    
    static let deleteItem = XHEmotion(title: "", imageName: "DeleteEmoticonBtn", imageUrl: nil)
    
}

class XHEmotionBag: NSObject,Codable {
    
    /// 与image互斥，当该值存在时image必为空，image优先级要高于imageUrl
    private(set) var imageUrl: String?
    
    private(set) var title: String?
    
    /// 与imageUrl互斥，当该值存在时imageUrl为空
    private(set) var image: UIImage?
    
    private(set) var emotions: [XHEmotion]!
    
    static let defaultBag: XHEmotionBag = {
        let temp = XHEmotionBag()
        temp.numberOfLines = 3
        temp.numbersInLine = 9
        temp.isNeedAutoAddDeleteItem = true
        let path = Bundle.main.path(forResource: "Emotions", ofType: "plist")!
        let arr = NSArray(contentsOfFile: path) as! [[String: String]]
        temp.emotions = arr.map({ (dic) -> XHEmotion in
            var emotion = XHEmotion()
            emotion.title = dic["title"]
            emotion.imageName = dic["imageName"]
            return emotion
        })
        temp.resizeItems()
        temp.image = #imageLiteral(resourceName: "EmotionsEmoji")
        return temp
    }()
    
    private(set) var numbersInLine: Int = 5
    
    private(set) var numberOfLines: Int = 2
    
    private(set) var isNeedAutoAddDeleteItem: Bool = false
    
    private func resizeItems() {
        var temp = [XHEmotion]()
        let numberInSection = numbersInLine * numberOfLines
        for index in 0 ..< emotions.count {
            temp.append(emotions[index])
            if isNeedAutoAddDeleteItem {
                if (index + 1) % (numberInSection - 1) == 0 {
                    temp.append(.deleteItem)
                }
            }
        }
        let rest = temp.count % numberInSection
        if rest > 0 {
            for _ in rest ..< (numberInSection - 1) {
                temp.append(.spaceItem)
            }
            if isNeedAutoAddDeleteItem {
                temp.append(.deleteItem)
            } else {
                temp.append(.spaceItem)
            }
        }
        emotions = temp
    }
    
    var numberOfSections: Int {
        return emotions.count / (numbersInLine * numberOfLines)
    }
    
    enum CodingKeys: CodingKey {
        case imageUrl,title,emotions,numbersInLine,numberOfLines,isNeedAutoAddDeleteItem
    }
    
    var isSelected: Bool = false
    
    var beginSection: Int = 0
    
    static let customBag: XHEmotionBag = {
        let temp = XHEmotionBag()
        temp.image = #imageLiteral(resourceName: "EmotionCustomHL")
        var emotion = XHEmotion()
        emotion.imageName = "Emoticon_tusiji_icon"
        temp.emotions = [emotion]
        temp.resizeItems()
        return temp
    }()

}

protocol XHChatBarExpressionKeyboardDelegate: XHChatBarKeyboardDelegate {
    
    func keyboard(_ keyboard: XHChatBarExpressionKeyboard,shouldEnter emotion: XHEmotion)
    
    func keyboardShouldAddEmotionBag(_ keyboard: XHChatBarExpressionKeyboard)
    
    func keyboardShouldSend(_ keyboard: XHChatBarExpressionKeyboard)
    
    func keyboard(_ keyboard: XHChatBarExpressionKeyboard,shouldSend emotion: XHEmotion)
    
    func keyboardShouldSetEmotionBags(_ keyboard: XHChatBarExpressionKeyboard)
    
}

protocol XHEmotionKeyboardAssociatedInputView: NSObjectProtocol {
    
    var associatedText: String? { get }
    
    var notificationName: Notification.Name { get }
    
    func clearText()
    
}

extension UITextView: XHEmotionKeyboardAssociatedInputView {
    
    var associatedText: String? {
        return text
    }
    
    var notificationName: Notification.Name {
        return .UITextViewTextDidChange
    }
    
    func clearText() {
        text = ""
    }
    
}

extension UITextField: XHEmotionKeyboardAssociatedInputView {
    
    var associatedText: String? {
        return text
    }
    
    var notificationName: Notification.Name {
        return .UITextFieldTextDidChange
    }
    
    func clearText() {
        text = nil
    }
    
}

class XHChatBarMoreKeyboard: XHChatBarKeyboard {
    
    static let shared = XHChatBarMoreKeyboard()
    
    private weak var _delegate: XHChatBarMoreKeyboardDelegate?
    
    override weak var delegate: XHChatBarKeyboardDelegate? {
        set {
            if let temp = newValue as? XHChatBarMoreKeyboardDelegate {
                _delegate = temp
            } else {
                _delegate = nil
            }
        }
        get {
            return _delegate
        }
    }
    
    private let actions = XHChatBarActionType.allMoreActionTypes()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        flowLayout.itemSize = CGSize(width: 60, height: 60)
        let margin = (bounds.width - 4 * 60) / 5
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = 11
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: margin, bottom: 10, right: margin)
        colletionView.heightAnchor.constraint(equalToConstant: collectionHeight + 34).isActive = true
        colletionView.register(XHChatBarMoreKeyboardCell.self, forCellWithReuseIdentifier: "cell")
        pageControl.numberOfPages = (actions.count + 7) / 8
        pageControl.addTarget(self, action: #selector(didSelectPage(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didSelectPage(_ pageControl: UIPageControl) {
        colletionView.setContentOffset(CGPoint(x: CGFloat(pageControl.currentPage) * colletionView.bounds.width , y: 0), animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (actions.count + 7) / 8
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XHChatBarMoreKeyboardCell
        cell.actionType = getActionTypeAt(indexPath)
        return cell
    }
    
    private func getActionTypeAt(_ indexPath: IndexPath) -> XHChatBarActionType? {
        let index = indexPath.item / 2 + (indexPath.item % 2) * 4 + indexPath.section * 8
        if index > actions.count - 1 {
            return nil
        }
        return actions[index]
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard getActionTypeAt(indexPath) != nil else { return }
        if let cell = collectionView.cellForItem(at: indexPath),let imageView = cell.backgroundView as? UIImageView {
            imageView.image = #imageLiteral(resourceName: "sharemore_other_HL")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard getActionTypeAt(indexPath) != nil else { return }
        if let cell = collectionView.cellForItem(at: indexPath),let imageView = cell.backgroundView as? UIImageView {
            imageView.image = #imageLiteral(resourceName: "sharemore_other")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let type = getActionTypeAt(indexPath) else { return }
        _delegate?.keyboard(self, didSelectAction: type)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    class XHChatBarMoreKeyboardCell: UICollectionViewCell {
        
        private let iconView = UIImageView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundView = UIImageView()
            contentView.addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            iconView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor).isActive = true
            iconView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var actionType: XHChatBarActionType? {
            didSet {
                if let type = actionType {
                    iconView.image = type.iconImage
                    let imageView = backgroundView as? UIImageView
                    imageView?.image = #imageLiteral(resourceName: "sharemore_other")
                }
            }
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            let imageView = backgroundView as? UIImageView
            imageView?.image = nil
            iconView.image = nil
        }
        
    }
    
}

fileprivate extension XHChatBarActionType {
    
    var iconImage: UIImage? {
        switch self {
        case .photoLibrary:
            return #imageLiteral(resourceName: "sharemore_pic")
        case .takePhoto:
            return #imageLiteral(resourceName: "sharemore_video")
        case .videoCall:
            return #imageLiteral(resourceName: "sharemore_videovoip")
        case .location:
            return #imageLiteral(resourceName: "sharemore_location")
        case .redbag:
            return #imageLiteral(resourceName: "sharemore_lucybag")
        case .transfer:
            return #imageLiteral(resourceName: "sharemorePay")
        case .speechInput:
            return #imageLiteral(resourceName: "sharemore_voiceinput")
        case .collection:
            return #imageLiteral(resourceName: "sharemore_myfav")
        case .infoCard:
            return #imageLiteral(resourceName: "sharemore_friendcard")
        case .files:
            return #imageLiteral(resourceName: "sharemore_files")
        case .wallet:
            return #imageLiteral(resourceName: "sharemore_wallet")
        default:
            return nil
        }
    }
    
}

protocol XHChatBarMoreKeyboardDelegate: XHChatBarKeyboardDelegate {
    
    func keyboard(_ keyboard: XHChatBarMoreKeyboard,didSelectAction type: XHChatBarActionType)
    
}
