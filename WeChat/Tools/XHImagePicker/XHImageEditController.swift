//
//  XHImageEditController.swift
//  WeChat
//
//  Created by Li on 2018/9/10.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHImageEditController: UIViewController {
    
    private(set) var originalImage: UIImage
    
    init(image: UIImage) {
        originalImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var zoomableView: XHZoomableView = {
        let drawboard = XHImageEditboard(content: originalImage)
        drawboard.sizeToFit()
        drawboard.isUserInteractionEnabled = false
        drawboard.addObserver(self, forKeyPath: "currentImage", options: .new, context: nil)
        let temp = XHZoomableView(frame: .zero, zoomView: drawboard)
        temp.doubleTapGestureRecognizer.isEnabled = false
        temp.delegate = self
        return temp
    }()
    
    private var drawboard: XHImageEditboard {
        return zoomableView.zoomView as! XHImageEditboard
    }
    
    private var imageLeftConstraint: NSLayoutConstraint!
    
    private var imageTopConstraint: NSLayoutConstraint!
    
    private let navigationBar = XHNavigationBar()
    
    private let editBar = XHImageEditBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        view.addSubview(zoomableView)
        zoomableView.translatesAutoresizingMaskIntoConstraints = false
        zoomableView.maximumZoomScale = 3
        imageLeftConstraint = zoomableView.leftAnchor.constraint(equalTo: view.leftAnchor)
        imageLeftConstraint.isActive = true
        zoomableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        zoomableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageTopConstraint = zoomableView.topAnchor.constraint(equalTo: view.topAnchor)
        imageTopConstraint.isActive = true
        configureNavigationBar()
        configureEditBar()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func configureNavigationBar() {
        let cancelItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelEditing))
        cancelItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13),.foregroundColor: UIColor.white], for: .normal)
        let doneItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(endEditing))
        doneItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13),.foregroundColor: UIColor.main], for: .normal)
        let fixItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        navigationBar.items = [cancelItem,fixItem,doneItem]
        view.addSubview(navigationBar)
        navigationBar.barTintColor = UIColor(hex: 0x282828, alpha: 0.2)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBar.bottomAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor, constant: 44).isActive = true
    }
    
    @objc private func cancelEditing() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func endEditing() {
        
    }
    
    private func configureEditBar() {
        editBar.delegate = self
        view.addSubview(editBar)
        editBar.translatesAutoresizingMaskIntoConstraints = false
        editBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        editBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        editBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let drawboard = object as? XHDrawboard {
            if let key = keyPath,key == "currentImage" {
                editBar.setCanUndo(drawboard.canUndo, for: .pen)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension XHImageEditController: XHZoomableViewDelegate {
    
    func zoomableView(_ zoomableView: XHZoomableView, didEndZoomingAtScale scale: CGFloat) {
        drawboard.currentLineWidth /= scale
    }
    
}

extension XHImageEditController: XHImageEditBarDelegate {
    
    fileprivate func editBar(_ editBar: XHImageEditBar, didSelect editType: XHImageEditType,info: Any?) {
        switch editType {
        case .pen:
            drawboard.isUserInteractionEnabled = true
            zoomableView.isScrollEnabled = false
            if let color = info as? UIColor {
                drawboard.currentLineColor = color
            }
        default:
            break
        }
    }
    
    fileprivate func editBar(_ editBar: XHImageEditBar, didDeselect editType: XHImageEditType) {
        if editType == .pen {
            drawboard.isUserInteractionEnabled = false
            zoomableView.isScrollEnabled = true
        }
    }
    
    fileprivate func editBar(_ editBar: XHImageEditBar, shouldDrawLineWith color: UIColor) {
        drawboard.currentLineColor = color
    }
    
    fileprivate func editBar(_ editBar: XHImageEditBar, shouldUndoFor editType: XHImageEditType) {
        switch editType {
        case .pen:
            drawboard.undo()
        default:
            break
        }
    }
    
}

fileprivate enum XHImageEditType: Int {
    case pen,emotion,text,mosaic,crop
    
    var iconName: String {
        switch self {
        case .pen:
            return "EditImagePenToolBtn"
        case .emotion:
            return "EditImageEmotionToolBtn"
        case .text:
            return "EditImageTextToolBtn"
        case .mosaic:
            return "EditImageMosaicToolBtn"
        case .crop:
            return "EditImageCropToolBtn"
        }
    }
    
}

fileprivate class XHImageEditboard: XHDrawboard {
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let width = min(size.width, UIScreen.main.bounds.width - 20)
        let scale = size.width / width
        let height = size.height / scale
        return CGSize(width: width, height: height)
    }
    
}

fileprivate class XHImageEditBar: UIView {
    
    private let toolBar = XHTranslucentToolBar()
    
    private var selectItem: UIButton?
    
    weak var delegate: XHImageEditBarDelegate?
    
    private let subBarContainer = UIView()
    
    private var subBarContainerConstraint: NSLayoutConstraint!
    
    var scale: CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0x282828, alpha: 0.2)
        addSubview(subBarContainer)
        subBarContainer.translatesAutoresizingMaskIntoConstraints = false
        subBarContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subBarContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        subBarContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        addSubview(toolBar)
        subBarContainer.bottomAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
        subBarContainerConstraint = subBarContainer.heightAnchor.constraint(equalToConstant: 0)
        subBarContainerConstraint.isActive = true
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        toolBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        configureBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureBar() {
        let fixItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let types: [XHImageEditType] = [.pen,.emotion,.text,.mosaic,.crop]
        let items = types.map { (type) -> UIBarButtonItem in
            let button = buttonWithImageName(type.iconName)
            button.tag = type.rawValue
            return UIBarButtonItem(customView: button)
        }
        var allItems = [UIBarButtonItem]()
        for item in items {
            allItems.append(contentsOf: [item,fixItem])
        }
        allItems.removeLast()
        toolBar.items = allItems
    }
    
    private func buttonWithImageName(_ imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        if let selectImage = UIImage(named: imageName + "_HL") {
            button.setImage(selectImage, for: .selected)
        }
        if let highlightImage = UIImage(named: imageName + "_SEL_HL") {
            button.setImage(highlightImage, for: .highlighted)
        }
        button.sizeToFit()
        button.addTarget(self, action: #selector(didSelectEditItem(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func didSelectEditItem(_ sender: UIButton) {
        guard let type = XHImageEditType(rawValue: sender.tag) else { return }
        if sender.image(for: .selected) != nil {
            if let selectedItem = selectItem {
                selectedItem.isSelected = false
                let selectType = XHImageEditType(rawValue: selectedItem.tag)!
                didDeselectEditType(selectType)
            }
            guard selectItem != sender else {
                selectItem = nil
                return
            }
            selectItem = sender
            sender.isSelected = true
            didSelectEditType(type)
        } else {
            didSelectEditType(type)
        }
    }
    
    private lazy var penBar: XHImageEditPenBar = {
        let temp = XHImageEditPenBar()
        temp.uiDelegate = self
        return temp
    }()
    
    private func didSelectEditType(_ type: XHImageEditType) {
        var info: Any?
        switch type {
        case .pen:
            subBarContainer.addSubview(penBar)
            penBar.translatesAutoresizingMaskIntoConstraints = false
            penBar.leftAnchor.constraint(equalTo: subBarContainer.leftAnchor).isActive = true
            penBar.bottomAnchor.constraint(equalTo: subBarContainer.bottomAnchor).isActive = true
            penBar.rightAnchor.constraint(equalTo: subBarContainer.rightAnchor).isActive = true
            subBarContainerConstraint.isActive = false
            penBar.topAnchor.constraint(equalTo: subBarContainer.topAnchor).isActive = true
            info = penBar.currentColor
        default:
            break
        }
        delegate?.editBar(self, didSelect: type,info: info)
    }
    
    private func didDeselectEditType(_ type: XHImageEditType) {
        switch type {
        case .pen:
            penBar.removeFromSuperview()
            subBarContainerConstraint.isActive = true
        default:
            break
        }
        delegate?.editBar(self, didDeselect: type)
    }
    
}

extension XHImageEditBar: XHImageEditPenBarDelegate {
    
    func penBar(_ penBar: XHImageEditPenBar, didSelect color: XHImageEditPenColor) {
        delegate?.editBar(self, shouldDrawLineWith: color.color)
    }
    
    func penBarShouldUndo(_ penBar: XHImageEditPenBar) {
        delegate?.editBar(self, shouldUndoFor: .pen)
    }
    
    func setCanUndo(_ flag: Bool,for editType: XHImageEditType) {
        switch editType {
        case .pen:
            penBar.canUndo = flag
        default:
            break
        }
    }
    
}

fileprivate protocol XHImageEditBarDelegate: NSObjectProtocol {
    
    func editBar(_ editBar: XHImageEditBar,didSelect editType: XHImageEditType,info: Any?)
    
    func editBar(_ editBar: XHImageEditBar,didDeselect editType: XHImageEditType)
    
    func editBar(_ editBar: XHImageEditBar,shouldDrawLineWith color: UIColor)
    
    func editBar(_ editBar: XHImageEditBar,shouldUndoFor editType: XHImageEditType)
    
}

fileprivate enum XHImageEditPenColor: Int {
    case white,black,red,yellow,green,blue,purple,magenta
    
    var iconName: String {
        return "EditImageColorDot_\(rawValue)_"
    }
    
    var color: UIColor {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .magenta:
            return .magenta
        }
    }
}

fileprivate class XHImageEditPenBar: XHTranslucentToolBar {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    private var selectItem: UIButton?
    
    private let revokeButton = UIButton(type: .custom)
    
    weak var uiDelegate: XHImageEditPenBarDelegate?
    
    var canUndo: Bool {
        set {
            revokeButton.isEnabled = newValue
        }
        get {
            return revokeButton.isEnabled
        }
    }
    
    var currentColor: UIColor? {
        if let selectItem = self.selectItem {
            let color = XHImageEditPenColor(rawValue: selectItem.tag)
            return color?.color
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureItems()
        canUndo = false
        let line = UIView()
        addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        line.backgroundColor = UIColor(hex: 0x393939)
        if let button = items?.first?.customView as? UIButton {
            didSelectColor(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureItems() {
        let fixItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let types: [XHImageEditPenColor] = [.white,.black,.red,.yellow,.green,.blue,.purple,.magenta]
        let items = types.map { (type) -> UIBarButtonItem in
            let button = buttonWithImageName(type.iconName)
            button.tag = type.rawValue
            return UIBarButtonItem(customView: button)
        }
        var allItems = [UIBarButtonItem]()
        for item in items {
            allItems.append(contentsOf: [item,fixItem])
        }
        revokeButton.setImage(#imageLiteral(resourceName: "EditImageRevokeDisable"), for: .disabled)
        revokeButton.setImage(#imageLiteral(resourceName: "EditImageRevokeEnable"), for: .normal)
        revokeButton.addTarget(self, action: #selector(shouldRevokeLastDraw(_:)), for: .touchUpInside)
        revokeButton.sizeToFit()
        let revokeItem = UIBarButtonItem(customView: revokeButton)
        allItems.append(revokeItem)
        self.items = allItems
    }
    
    private func buttonWithImageName(_ imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName + "unsel"), for: .normal)
        button.setImage(UIImage(named: imageName + "sel"), for: .selected)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didSelectColor(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func didSelectColor(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        sender.isSelected = !sender.isSelected
        selectItem?.isSelected = false
        selectItem = sender
        uiDelegate?.penBar(self, didSelect: XHImageEditPenColor(rawValue: sender.tag)!)
    }
    
    @objc private func shouldRevokeLastDraw(_ sender: UIButton) {
        uiDelegate?.penBarShouldUndo(self)
    }
}

fileprivate protocol XHImageEditPenBarDelegate: NSObjectProtocol {
    
    func penBar(_ penBar: XHImageEditPenBar,didSelect color: XHImageEditPenColor)
    
    func penBarShouldUndo(_ penBar: XHImageEditPenBar)
    
}
