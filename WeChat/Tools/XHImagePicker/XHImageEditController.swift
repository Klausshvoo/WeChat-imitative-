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
        let drawboard = XHImageEditboard(image: originalImage)
        drawboard.isUserInteractionEnabled = false
        drawboard.delegate = self
        let temp = XHZoomableView(frame: .zero, zoomView: drawboard)
        temp.setZoomSize(drawboard.intrinsicContentSize)
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
        zoomableView.backgroundColor = UIColor.black
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension XHImageEditController: XHZoomableViewDelegate {
    
    func zoomableView(_ zoomableView: XHZoomableView, didEndZoomingAtScale scale: CGFloat) {
        drawboard.scale = scale
    }
    
}

extension XHImageEditController: XHImageEditboardDelegate {
    
    fileprivate func eidtboard(_ eidtboard: XHImageEditboard, didBeginDrawingWithBrushType type: XHImageEditboardBrushType) {
        view.bringSubviewToFront(zoomableView)
    }
    
    fileprivate func eidtboard(_ eidtboard: XHImageEditboard, didEndDrawingWithBrushType type: XHImageEditboardBrushType) {
        view.sendSubviewToBack(zoomableView)
        editBar.setCanUndo(eidtboard.canUndo(for: type), for: editBar.editType!)
    }

}

extension XHImageEditController: XHImageEditBarDelegate {
    
    fileprivate func editBar(_ editBar: XHImageEditBar, didSelect editType: XHImageEditType,info: Any?) {
        switch editType {
        case .pen:
            drawboard.brushType = .line
            drawboard.isUserInteractionEnabled = true
            zoomableView.isScrollEnabled = false
            if let color = info as? UIColor {
                drawboard.lineColor = color
            }
        case .mosaic:
            drawboard.brushType = .mosaic
            drawboard.isUserInteractionEnabled = true
            zoomableView.isScrollEnabled = false
        default:
            break
        }
    }
    
    fileprivate func editBar(_ editBar: XHImageEditBar, didDeselect editType: XHImageEditType) {
        drawboard.isUserInteractionEnabled = false
        zoomableView.isScrollEnabled = true
    }
    
    fileprivate func editBar(_ editBar: XHImageEditBar, shouldDrawLineWith color: UIColor) {
        drawboard.lineColor = color
    }
    
    fileprivate func editBar(_ editBar: XHImageEditBar, shouldUndoFor editType: XHImageEditType) {
        var canUndo: Bool
        switch editType {
        case .pen:
            drawboard.undo(for: .line)
            canUndo = drawboard.canUndo(for: .line)
        case .mosaic:
            drawboard.undo(for: .mosaic)
            canUndo = drawboard.canUndo(for: .mosaic)
        default:
            canUndo = false
            break
        }
        editBar.setCanUndo(canUndo, for: editType)
    }
    
    fileprivate func editBar(_ editBar: XHImageEditBar, shouldDrawMosaicWith type: XHImageEditMosaicType) {
        
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

enum XHImageEditboardBrushType {
    case line,mosaic
}

fileprivate class XHImageEditboard: UIView {
    
    weak var delegate: XHImageEditboardDelegate?
    
    var brushType: XHImageEditboardBrushType = .line {
        didSet {
            drawboard.isUserInteractionEnabled = brushType == .line
        }
    }
    
    var scale: CGFloat = 1 {
        didSet {
            drawboard.scale = scale
            mosaicView.scale = scale
        }
    }
    
    var lineColor: UIColor {
        set {
            drawboard.lineColor = newValue
        }
        get {
            return drawboard.lineColor
        }
    }
    
    private var mosaicView: XHMosaicView
    
    private let drawboard = XHDrawboard()
    
    init(image: UIImage) {
        mosaicView = XHMosaicView(content: image)
        super.init(frame: .zero)
        addSubview(mosaicView)
        mosaicView.translatesAutoresizingMaskIntoConstraints = false
        mosaicView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mosaicView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mosaicView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mosaicView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mosaicView.delegate = self
        addSubview(drawboard)
        drawboard.translatesAutoresizingMaskIntoConstraints = false
        drawboard.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        drawboard.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        drawboard.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        drawboard.topAnchor.constraint(equalTo: topAnchor).isActive = true
        drawboard.delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        let size = intrinsicContentSize
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let size = mosaicView.intrinsicContentSize
        let width = min(size.width, UIScreen.main.bounds.width - 20)
        let scale = size.width / width
        let height = size.height / scale
        return CGSize(width: width, height: height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    func undo(for type: XHImageEditboardBrushType) {
        switch type {
        case .line:
            drawboard.undo()
        case .mosaic:
            mosaicView.undo()
        }
    }
    
    func canUndo(for type: XHImageEditboardBrushType) -> Bool {
        switch type {
        case .line:
            return drawboard.canUndo
        case .mosaic:
            return mosaicView.canUndo
        }
    }
    
}

extension XHImageEditboard: XHDrawboardDelegate {
    
    func drawboardDidBeginDrawing(_ drawboard: XHDrawboard) {
        delegate?.eidtboard(self, didBeginDrawingWithBrushType: .line)
    }
    
    func drawboardDidEndDrawing(_ drawboard: XHDrawboard) {
        delegate?.eidtboard(self, didEndDrawingWithBrushType: .line)
    }
}

extension XHImageEditboard: XHMosaicViewDelegate {
    
    func mosaicViewDidBeginDrawing(_ mosaicView: XHMosaicView) {
        delegate?.eidtboard(self, didBeginDrawingWithBrushType: .mosaic)
    }
    
    func mosaicViewDidEndDrawing(_ mosaicView: XHMosaicView) {
        delegate?.eidtboard(self, didEndDrawingWithBrushType: .mosaic)
    }
    
}

fileprivate protocol XHImageEditboardDelegate: NSObjectProtocol {
    
    func eidtboard(_ eidtboard: XHImageEditboard,didBeginDrawingWithBrushType type: XHImageEditboardBrushType)
    
    func eidtboard(_ eidtboard: XHImageEditboard,didEndDrawingWithBrushType type: XHImageEditboardBrushType)
    
}

fileprivate class XHImageEditBar: UIView {
    
    private let toolBar = XHTranslucentToolBar()
    
    private var selectItem: UIButton?
    
    var editType: XHImageEditType? {
        if let selectItem = self.selectItem {
            return XHImageEditType(rawValue: selectItem.tag)
        }
        return nil
    }
    
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
    
    private lazy var mosaicBar: XHImageEditMosaicBar = {
        let temp = XHImageEditMosaicBar()
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
            subBarContainerConstraint.isActive = false
            penBar.topAnchor.constraint(equalTo: subBarContainer.topAnchor).isActive = true
            info = penBar.currentColor
        case .mosaic:
            subBarContainer.addSubview(mosaicBar)
            mosaicBar.translatesAutoresizingMaskIntoConstraints = false
            mosaicBar.leftAnchor.constraint(equalTo: subBarContainer.leftAnchor).isActive = true
            mosaicBar.bottomAnchor.constraint(equalTo: subBarContainer.bottomAnchor).isActive = true
            subBarContainerConstraint.isActive = false
            mosaicBar.topAnchor.constraint(equalTo: subBarContainer.topAnchor).isActive = true
            info = mosaicBar.type
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
        case .mosaic:
            mosaicBar.removeFromSuperview()
            subBarContainerConstraint.isActive = true
        default:
            break
        }
        delegate?.editBar(self, didDeselect: type)
    }
    
    func setCanUndo(_ flag: Bool,for editType: XHImageEditType) {
        switch editType {
        case .pen:
            penBar.canUndo = flag
        case .mosaic:
            mosaicBar.canUndo = flag
        default:
            break
        }
    }
    
}

extension XHImageEditBar: XHImageEditPenBarDelegate {
    
    func penBar(_ penBar: XHImageEditPenBar, didSelect color: XHImageEditPenColor) {
        delegate?.editBar(self, shouldDrawLineWith: color.color)
    }
    
    func penBarShouldUndo(_ penBar: XHImageEditPenBar) {
        delegate?.editBar(self, shouldUndoFor: .pen)
    }
    
}

extension XHImageEditBar: XHImageEditMosaicBarDelegate {
    
    func mosaicBar(_ mosaicBar: XHImageEditMosaicBar, didSelect type: XHImageEditMosaicType) {
        delegate?.editBar(self, shouldDrawMosaicWith: type)
    }
    
    func mosaicBarShouldUndo(_ mosaicBar: XHImageEditMosaicBar) {
        delegate?.editBar(self, shouldUndoFor: .mosaic)
    }
    
}

fileprivate protocol XHImageEditBarDelegate: NSObjectProtocol {
    
    func editBar(_ editBar: XHImageEditBar,didSelect editType: XHImageEditType,info: Any?)
    
    func editBar(_ editBar: XHImageEditBar,didDeselect editType: XHImageEditType)
    
    func editBar(_ editBar: XHImageEditBar,shouldDrawLineWith color: UIColor)
    
    func editBar(_ editBar: XHImageEditBar,shouldUndoFor editType: XHImageEditType)
    
    func editBar(_ editBar: XHImageEditBar,shouldDrawMosaicWith type: XHImageEditMosaicType)
    
}

fileprivate protocol XHItemEnum: CaseIterable {
    
    var rawValue: Int { get }
    
    var iconName: String { get }
    
    var width: CGFloat? { get }
    
    var hasSuffix: Bool { get }
    
}

extension XHItemEnum {
    
    func buttonWithTarget(_ target: Any,action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        var normalName = iconName
        var selectName = iconName
        if hasSuffix {
            normalName += "unsel"
            selectName += "sel"
        } else {
            selectName += "_HL"
        }
        button.setImage(UIImage(named: normalName), for: .normal)
        button.setImage(UIImage(named: selectName), for: .selected)
        button.setImage(UIImage(named: selectName), for: .highlighted)
        button.sizeToFit()
        if let width = width {
            var bounds = button.bounds
            bounds.size.width = width
            button.bounds = bounds
        }
        button.tag = rawValue
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
    
    static func allBarButtonItems(target: Any,action: Selector,hasSuffix: Bool) -> [UIBarButtonItem] {
        let fixItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var allItems = [UIBarButtonItem]()
        for type in allCases {
            let button = type.buttonWithTarget(target, action: action)
            button.tag = type.rawValue
            let item = UIBarButtonItem(customView: button)
            allItems.append(contentsOf: [item,fixItem])
        }
        return allItems
    }
    
}

fileprivate class XHImageEditTypeBar<T: XHItemEnum>: XHTranslucentToolBar {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    fileprivate var selectItem: UIButton?
    
    var revokeButtonWidth: CGFloat? {
        return nil
    }
    
    private lazy var revokeButton: UIButton = {
        let temp = UIButton(type: .custom)
        temp.setImage(#imageLiteral(resourceName: "EditImageRevokeDisable"), for: .disabled)
        temp.setImage(#imageLiteral(resourceName: "EditImageRevokeEnable"), for: .normal)
        temp.sizeToFit()
        temp.addTarget(self, action: #selector(shouldRevokeLastDraw(_:)), for: .touchUpInside)
        if let width = revokeButtonWidth {
            var bounds = temp.bounds
            bounds.size.width = width
            temp.bounds = bounds
        }
        return temp
    }()
    
    var canUndo: Bool {
        set {
            revokeButton.isEnabled = newValue
        }
        get {
            return revokeButton.isEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureItems()
        let line = UIView()
        addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        line.backgroundColor = UIColor(hex: 0x393939)
        if let button = items?.first?.customView as? UIButton {
            didSelectType(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureItems() {
        var allItems = T.allBarButtonItems(target: self, action: #selector(didSelectType(_:)), hasSuffix: true)
        let revokeItem = UIBarButtonItem(customView: revokeButton)
        revokeButton.isEnabled = false
        allItems.append(revokeItem)
        self.items = allItems
    }
    
    @objc func didSelectType(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        sender.isSelected = !sender.isSelected
        selectItem?.isSelected = false
        selectItem = sender
    }
    
    @objc func shouldRevokeLastDraw(_ sender: UIButton) {}
    
}

fileprivate enum XHImageEditPenColor: Int,XHItemEnum {
    case white,black,red,yellow,green,blue,purple,magenta
    
    var iconName: String {
        return "EditImageColorDot_\(rawValue)_"
    }
    
    var hasSuffix: Bool {
        return true
    }
    
    var width: CGFloat? {
        return nil
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

fileprivate class XHImageEditPenBar: XHImageEditTypeBar<XHImageEditPenColor> {
    
    weak var uiDelegate: XHImageEditPenBarDelegate?
    
    var currentColor: UIColor? {
        if let selectItem = self.selectItem {
            let color = XHImageEditPenColor(rawValue: selectItem.tag)
            return color?.color
        }
        return nil
    }
    
    override func didSelectType(_ sender: UIButton) {
        super.didSelectType(sender)
        guard sender.isSelected else { return }
        uiDelegate?.penBar(self, didSelect: XHImageEditPenColor(rawValue: sender.tag)!)
    }
    
    override func shouldRevokeLastDraw(_ sender: UIButton) {
        uiDelegate?.penBarShouldUndo(self)
    }
}

fileprivate protocol XHImageEditPenBarDelegate: NSObjectProtocol {
    
    func penBar(_ penBar: XHImageEditPenBar,didSelect color: XHImageEditPenColor)
    
    func penBarShouldUndo(_ penBar: XHImageEditPenBar)
    
}

fileprivate enum XHImageEditMosaicType: Int,XHItemEnum {
    case traditional,brush
    
    var iconName: String {
        switch self {
        case .traditional:
            return "EditImageTraditionalMosaicBtn"
        case .brush:
            return "EditImageBrushMosaicBtn"
        }
    }
    
    var width: CGFloat? {
        return UIScreen.main.bounds.width * 0.28
    }
    
    var hasSuffix: Bool {
        return false
    }
    
}

fileprivate class XHImageEditMosaicBar: XHImageEditTypeBar<XHImageEditMosaicType> {
    
    weak var uiDelegate: XHImageEditMosaicBarDelegate?
    
    var type: XHImageEditMosaicType = .traditional
    
    override var revokeButtonWidth: CGFloat? {
        return UIScreen.main.bounds.width * 0.2
    }
    
    override func didSelectType(_ sender: UIButton) {
        super.didSelectType(sender)
        guard sender.isSelected else { return }
        uiDelegate?.mosaicBar(self, didSelect: XHImageEditMosaicType(rawValue: sender.tag)!)
    }
    
    override func shouldRevokeLastDraw(_ sender: UIButton) {
        uiDelegate?.mosaicBarShouldUndo(self)
    }
    
}

fileprivate protocol XHImageEditMosaicBarDelegate: NSObjectProtocol {
    
    func mosaicBar(_ mosaicBar: XHImageEditMosaicBar,didSelect type: XHImageEditMosaicType)
    
    func mosaicBarShouldUndo(_ mosaicBar: XHImageEditMosaicBar)
    
}

