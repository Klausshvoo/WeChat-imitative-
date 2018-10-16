//
//  XHImagePickerController.swift
//  WeChat
//
//  Created by Li on 2018/9/7.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit
import Photos

protocol XHPhotoLibraryAuthorization {}

extension XHPhotoLibraryAuthorization {
    
    func photoLibraryAuthorizationStatus(handler: @escaping (Bool)->Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            handler(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                handler(status == .authorized)
            }
        default:
            handler(false)
        }
    }
    
}

// MARK: - XHImagePickerControllerDelegate
@objc protocol XHImagePickerControllerDelegate: NSObjectProtocol {
    
    @objc optional func imagePickerDidCancel(_ picker: XHImagePickerController)
    
    func imagePickerController(_ picker: XHImagePickerController, didFinishPickingMediaAssets assets: [XHPhotoAsset])
    
}

// MARK: - XHImagePickerController
class XHImagePickerController: UINavigationController {
    
    weak var uiDelegate: XHImagePickerControllerDelegate?
    
    convenience init() {
        self.init(rootViewController: XHAlbumsController())
        setBlackBar()
        navigationBar.setBackgroundImage(UIImage(color: UIColor(hex: 0x282b35, alpha: 0.8)), for: .default)
    }
    
    var isMutableSelected: Bool = true
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSelect))
        if !viewControllers.isEmpty {
            viewController.hidesBottomBarWhenPushed = true
        }
//        viewController.navigationItem.backBarButtonItem?.title = "返回"
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc private func cancelSelect() {
        uiDelegate?.imagePickerDidCancel?(self)
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func didFinishPickingMediaAssets(_ assets: [XHPhotoAsset]) {
        uiDelegate?.imagePickerController(self, didFinishPickingMediaAssets: assets)
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }

}

// MARK: - XHAlbumsController

fileprivate class XHAlbumsController: UIViewController,XHPhotoLibraryAuthorization {
    
    private var albums: [XHAlbum]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        photoLibraryAuthorizationStatus { [weak self](granted) in
            DispatchQueue.main.async {
                self?.respondsAuthorizationStatus(granted)
            }
        }
    }
    
    private func respondsAuthorizationStatus(_ granted: Bool) {
        if !granted {
            let label = UILabel()
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 15)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.text = "请在iPhone的“设置-隐私-照片”选项中，允许微信访问你的手机相册"
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 64).isActive = true
            label.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 45).isActive = true
        } else {
            albums = XHAlbum.allAlbums()
            pushPhotoes(for: albums[0],animated: false)
            title = "照片"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        }
    }
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: view.bounds, style: .plain)
        temp.rowHeight = 56
        temp.register(XHAlbumCell.self, forCellReuseIdentifier: "cell")
        temp.dataSource = self
        temp.delegate = self
        return temp
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard title != nil else { return }
        guard tableView.superview == nil else { return }
        view.addSubview(tableView)
    }
    
    private func pushPhotoes(for album: XHAlbum,animated: Bool = true) {
        let photoesController = XHPhotoesController()
        photoesController.album = album
        navigationController?.pushViewController(photoesController, animated: animated)
    }
    
}

extension XHAlbumsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! XHAlbumCell
        cell.album = albums[indexPath.row]
        return cell
    }
    
}

extension XHAlbumsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pushPhotoes(for: albums[indexPath.row])
    }
    
}

fileprivate class XHAlbumCell: UITableViewCell {
    
    private let coverView = UIImageView(image: #imageLiteral(resourceName: "luckymoneyNewYearPictureDefaultIcon"))
    
    private let titleLabel = UILabel()
    
    private let countLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(coverView)
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        coverView.centerXAnchor.constraint(equalTo: contentView.leftAnchor, constant: 28).isActive = true
        coverView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor).isActive = true
        coverView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor).isActive = true
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 66).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        contentView.addSubview(countLabel)
        countLabel.font = UIFont.systemFont(ofSize: 15)
        countLabel.textColor = UIColor.grayText
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 20).isActive = true
        countLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var album: XHAlbum? {
        didSet {
            titleLabel.text = album?.localizedTitle
            countLabel.text = "(\(album?.assets.count ?? 0))"
            if let asset = album?.assets.last {
                asset.fetchCoverImage { [weak self](weakAsset) in
                    guard asset == weakAsset else { return }
                    self?.coverView.image = weakAsset.thumbImage
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.coverView.image = #imageLiteral(resourceName: "luckymoneyNewYearPictureDefaultIcon")
    }
    
}

fileprivate class XHAlbum: NSObject {
    
    private var collection: PHAssetCollection
    
    init(collection: PHAssetCollection) {
        self.collection = collection
        super.init()
    }
    
    lazy var assets: [XHPhotoAsset] = {
        return collection.photoes()
    }()
    
    static func allAlbums() -> [XHAlbum] {
        var temp = [PHAssetCollection]()
        temp.append(contentsOf: PHAssetCollection.albums(for: .smartAlbum))
        temp.append(contentsOf: PHAssetCollection.albums(for: .album))
        return temp.map{ XHAlbum(collection: $0) }
    }
    
    var localizedTitle: String? {
        return collection.localizedTitle
    }
    
}

fileprivate extension PHAssetCollection {
    
     static func albums(for type: PHAssetCollectionType) -> [PHAssetCollection] {
        var temp = [PHAssetCollection]()
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        let albums = PHAssetCollection.fetchAssetCollections(with: type, subtype: .any, options: options)
        albums.enumerateObjects { (album, _, _) in
            if album.assetCollectionSubtype == .smartAlbumUserLibrary {
                temp.insert(album, at: 0)
            } else if album.assetCollectionSubtype != .smartAlbumAllHidden {
                temp.append(album)
            }
        }
        return temp
    }
    
    func photoes() -> [XHPhotoAsset] {
        var temp = [XHPhotoAsset]()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(in: self, options: options)
        result.enumerateObjects({ (asset, _, _) in
            temp.append(XHPhotoAsset(asset: asset))
        })
        return temp
    }
    
}

// MARK: - XHPhotoesController
fileprivate let maxNumberOfSelectedItems = 9

fileprivate class XHPhotoesController: UIViewController {
    
    var album: XHAlbum! {
        didSet {
            title = album.localizedTitle
        }
    }
    
    private var collectionView: UICollectionView!
    
    private lazy var selectedAssets: [XHPhotoAsset] = []
    
    private lazy var isMutableSelected: Bool = {
        if let navigationController = self.navigationController as? XHImagePickerController {
            return navigationController.isMutableSelected
        }
        return true
    }()
    
    private lazy var selectBar = XHPhotoSelectBar(type: .preview)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        let width = (UIScreen.main.bounds.width - 5 * 5) / 4
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.minimumLineSpacing = 5
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: isMutableSelected ? 49 : 0, right: 5)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.background
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(isMutableSelected ? XHPhotoSelectedCell.self : XHPhotoCell.self, forCellWithReuseIdentifier:"cell")
        collectionView.isScrollEnabled = false
        if isMutableSelected {
            view.addSubview(selectBar)
            selectBar.delegate = self
            selectBar.translatesAutoresizingMaskIntoConstraints = false
            selectBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            selectBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            selectBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            selectBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -44).isActive = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !collectionView.isScrollEnabled {
            let count = album.assets.count
            if count > 0 {
                collectionView.scrollToItem(at: IndexPath(item: count - 1, section: 0), at: .top, animated: false)
            }
            collectionView.isScrollEnabled = true
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension XHPhotoesController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XHPhotoCell
        cell.asset = album.assets[indexPath.item]
        if let cell = cell as? XHPhotoSelectedCell {
            cell.delegate = self
        }
        if self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: cell)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension XHPhotoesController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedAssets.count < maxNumberOfSelectedItems else {
            UIAlertController.showCannotSelectMoreAlert(from: self)
            return
        }
        if isMutableSelected {
            browseAssets(album.assets, index: indexPath.item)
        }
    }
    
    private func browseAssets(_ assets: [XHPhotoAsset],index: Int) {
        let browseController = XHPhotoBrowseController()
        browseController.setAssets(assets, index: index)
        browseController.isUseOringinImage = selectBar.isUseOringinImage
        browseController.delegate = self
        navigationController?.pushViewController(browseController, animated: true)
    }
    
}

extension XHPhotoesController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let cell = previewingContext.sourceView as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)!
        let previewController = XHPhotoPreviewController()
        let asset = album.assets[indexPath.item]
        previewController.asset = asset
        var width: CGFloat
        var height: CGFloat
        if asset.originalSize.width < asset.originalSize.height {
            height = UIScreen.main.bounds.height
            width = asset.originalSize.width / asset.originalSize.height * height
        } else {
            width = UIScreen.main.bounds.width
            height = asset.originalSize.height / asset.originalSize.width * width
        }
        previewController.preferredContentSize = CGSize(width: width, height: height)
        return previewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let cell = previewingContext.sourceView as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)!
        let browseController = XHPhotoBrowseController()
        browseController.setAssets(album.assets, index: indexPath.item)
        browseController.delegate = self
        self.show(browseController, sender: self)
    }
    
    class XHPhotoPreviewController: UIViewController {
        
        var asset: XHPhotoAsset!
        
        private let imageView = UIImageView()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: preferredContentSize.width).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: preferredContentSize.height).isActive = true
            asset.requestOriginalImage { [weak self](image) in
                self?.imageView.image = image
            }
        }
        
    }
    
}



// MARK: - XHPhotoBrowseControllerDelegate
extension XHPhotoesController: XHPhotoBrowseControllerDelegate {
    
    func browseControllerShouldPopBackWithChanges(_ controller: XHPhotoBrowseController) {
        selectedAssets = album.assets.filter({ $0.isSelected })
        collectionView.reloadData()
        selectBar.isUseOringinImage = controller.isUseOringinImage
        selectBar.updateItemsStatus(selectCount: selectedAssets.count)
    }
    
    func browseControllerDidSelectMaxNumberOfAssets(_ controller: XHPhotoBrowseController) {
        for asset in album.assets {
            if !asset.isSelected {
                asset.selectable = false
            }
        }
    }
    
    func browseControllerDidDropMaxNumberOfAssets(_ controller: XHPhotoBrowseController) {
        for asset in album.assets {
            if !asset.selectable {
                asset.selectable = true
            }
        }
    }
    
}

// MARK: - XHPhotoSelectedCellDelegate
extension XHPhotoesController: XHPhotoSelectedCellDelegate {
    
    func photoSelectedCell(_ cell: XHPhotoSelectedCell, didSelect asset: XHPhotoAsset) {
        selectedAssets.append(asset)
        asset.selectedIndex = selectedAssets.count
        if selectedAssets.count == maxNumberOfSelectedItems {
            var indexPaths = [IndexPath]()
            for index in 0 ..< album.assets.count {
                let asset = album.assets[index]
                if !asset.isSelected {
                    asset.selectable = false
                    indexPaths.append(IndexPath(item: index, section: 0))
                }
            }
            if !indexPaths.isEmpty {
                collectionView.performBatchUpdates({[weak self] in
                    self?.collectionView.reloadItems(at: indexPaths)
                    }, completion: nil)
            }
        }
        selectBar.updateItemsStatus(selectCount: selectedAssets.count)
    }
    
    func photoSelectedCell(_ cell: XHPhotoSelectedCell, didDeselect asset: XHPhotoAsset) {
        var indexPaths = [IndexPath]()
        if selectedAssets.count == maxNumberOfSelectedItems {
            for index in 0 ..< album.assets.count {
                let asset = album.assets[index]
                if !asset.selectable {
                    asset.selectable = true
                    indexPaths.append(IndexPath(item: index, section: 0))
                }
            }
        }
        for index in asset.selectedIndex ..< selectedAssets.count {
            let asset = selectedAssets[index]
            asset.selectedIndex -= 1
            let item = album.assets.index(of: asset)!
            let indexPath = IndexPath(item: item, section: 0)
            indexPaths.append(indexPath)
        }
        selectedAssets.remove(at: asset.selectedIndex - 1)
        asset.selectedIndex = 0
        if !indexPaths.isEmpty {
            collectionView.performBatchUpdates({[weak self] in
                self?.collectionView.reloadItems(at: indexPaths)
            }, completion: nil)
        }
        selectBar.updateItemsStatus(selectCount: selectedAssets.count)
    }
    
}

fileprivate class XHPhotoCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    private let videoIconView = XHAssetVideoIconView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        contentView.addSubview(videoIconView)
        videoIconView.translatesAutoresizingMaskIntoConstraints = false
        videoIconView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        videoIconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        videoIconView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -10).isActive = true
        videoIconView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var asset: XHPhotoAsset! {
        didSet {
            asset.fetchCoverImage{ [weak self](asset) in
                if self?.asset == asset {
                    self?.imageView.image = asset.thumbImage
                }
            }
            if asset.mediaType != .image {
                videoIconView.isHidden = false
                videoIconView.duration = asset.durationDescription
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoIconView.isHidden = true
    }
    
}

fileprivate class XHAssetVideoIconView: UIView {
    
    private let durationLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let iconView = UIImageView(image: #imageLiteral(resourceName: "fileicon_video_wall"))
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        iconView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        iconView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        addSubview(durationLabel)
        durationLabel.font = UIFont.systemFont(ofSize: 11)
        durationLabel.textColor = UIColor.white
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 10).isActive = true
        durationLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        durationLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var duration: String! {
        didSet {
            durationLabel.text = duration
        }
    }
    
}

fileprivate class XHPhotoSelectedCell: XHPhotoCell {
    
    private let selectedButton = UIButton(type: .custom)
    
    private let selectedLable = UILabel()
    
    private let coverView = UIView()
    
    weak var delegate: XHPhotoSelectedCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectedButton)
        selectedButton.setImage(#imageLiteral(resourceName: "sharecard_done"), for: .normal)
        selectedButton.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        selectedButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        selectedButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        selectedButton.heightAnchor.constraint(equalTo: selectedButton.widthAnchor).isActive = true
        selectedButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        selectedButton.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
        contentView.addSubview(selectedLable)
        selectedLable.translatesAutoresizingMaskIntoConstraints = false
        selectedLable.textColor = UIColor.white
        selectedLable.font = UIFont.systemFont(ofSize: 12)
        selectedLable.backgroundColor = UIColor.main
        selectedLable.layer.cornerRadius = 11
        selectedLable.layer.masksToBounds = true
        selectedLable.textAlignment = .center
        selectedLable.centerXAnchor.constraint(equalTo: selectedButton.centerXAnchor).isActive = true
        selectedLable.centerYAnchor.constraint(equalTo: selectedButton.centerYAnchor).isActive = true
        selectedLable.widthAnchor.constraint(equalToConstant: 22).isActive = true
        selectedLable.heightAnchor.constraint(equalTo: selectedLable.widthAnchor).isActive = true
        selectedLable.isHidden = true
        contentView.addSubview(coverView)
        coverView.frame = bounds
        coverView.translatesAutoresizingMaskIntoConstraints = false
        coverView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        coverView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didSelect(_ sender: UIButton) {
        asset.isSelected = !asset.isSelected
        selectedLable.isHidden = !asset.isSelected
        if asset.isSelected {
            delegate?.photoSelectedCell(self, didSelect: asset)
            selectedLable.text = "\(asset.selectedIndex)"
            selectedLable.shakeAnimation()
        } else {
            delegate?.photoSelectedCell(self, didDeselect: asset)
        }
    }
    
    override var asset: XHPhotoAsset! {
        didSet {
            if asset.isSelected {
                selectedLable.isHidden = false
                selectedLable.text = "\(asset.selectedIndex)"
            }
            coverView.isHidden = asset.selectable
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedLable.isHidden = true
        coverView.isHidden = true
    }
    
}

fileprivate extension UILabel {
    
    func shakeAnimation() {
        animation {[weak self] in
            self?.animation()
        }
    }
    
    private func animation(completion: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {[weak self] in
            self?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { [weak self](_) in
            UIView.animate(withDuration: 0.1, animations: {
                self?.transform = .identity
            }, completion: { (_) in
                completion?()
            })
        }
    }
}

fileprivate protocol XHPhotoSelectedCellDelegate: NSObjectProtocol {
    
    func photoSelectedCell(_ cell: XHPhotoSelectedCell,didSelect asset: XHPhotoAsset)
    
    func photoSelectedCell(_ cell: XHPhotoSelectedCell,didDeselect asset: XHPhotoAsset)
    
}

// MARK: - XHPhotoSelectBarDelegate
extension XHPhotoesController: XHPhotoSelectBarDelegate {
    
    func selectBarDidRespondsTypeAction(_ bar: XHPhotoSelectBar) {
        browseAssets(selectedAssets, index: 0)
    }
    
    func selectBarShouldSendSelectedAssets(_ bar: XHPhotoSelectBar) {
        if let navigationController = self.navigationController as? XHImagePickerController {
            navigationController.didFinishPickingMediaAssets(selectedAssets)
        }
    }
    
}

enum XHPhotoSelectBarType {
    case preview,edit
}

fileprivate class XHPhotoSelectBar: UIView {
    
    private let typeButton = UIButton(type: .custom)
    
    private let sendButton = UIButton(type: .custom)
    
    private let originButton = XHPhotoSelectBarButton(type: .custom)
    
    var isUseOringinImage: Bool {
        set {
            originButton.isSelected = newValue
        }
        get {
            return originButton.isSelected
        }
    }
    
    var type: XHPhotoSelectBarType
    
    weak var delegate: XHPhotoSelectBarDelegate?
    
    init(type: XHPhotoSelectBarType) {
        self.type = type
        super.init(frame: .zero)
        backgroundColor = UIColor(hex: 0x282b35, alpha: 0.8)
        addSubview(typeButton)
        typeButton.translatesAutoresizingMaskIntoConstraints = false
        typeButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        typeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        typeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typeButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        typeButton.contentHorizontalAlignment = .left
        typeButton.setTitleColor(UIColor.white, for: .normal)
        typeButton.setTitleColor(UIColor.grayText, for: .disabled)
        typeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        typeButton.addTarget(self, action: #selector(shouldRespondTypeAction), for: .touchUpInside)
        addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: typeButton.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        sendButton.setTitle("发送", for: .normal)
        sendButton.layer.cornerRadius = 5
        sendButton.layer.masksToBounds = true
        sendButton.setBackgroundImage(UIImage(color: .main), for: .normal)
        sendButton.addTarget(self, action: #selector(shouldSend), for: .touchUpInside)
        switch type {
        case .preview:
            typeButton.setTitle("预览", for: .normal)
            typeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            sendButton.isEnabled = false
            typeButton.isEnabled = false
        case .edit:
            typeButton.setTitle("编辑", for: .normal)
            typeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        }
        addSubview(originButton)
        originButton.translatesAutoresizingMaskIntoConstraints = false
        originButton.setImage(#imageLiteral(resourceName: "FriendsSendsPicturesArtworkNIcon"), for: .normal)
        originButton.setImage(#imageLiteral(resourceName: "FriendsSendsPicturesArtworkIcon"), for: .selected)
        originButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        originButton.setTitle("原图", for: .normal)
        originButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        originButton.centerYAnchor.constraint(equalTo: typeButton.centerYAnchor).isActive = true
        originButton.addTarget(self, action: #selector(shouldUseOriginImage(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateItemsStatus(selectCount: Int) {
        if type == .preview {
            typeButton.isEnabled = selectCount > 0
            sendButton.isEnabled = selectCount > 0
        }
        if selectCount > 0 {
            sendButton.setTitle("发送(\(selectCount))", for: .normal)
        } else {
            sendButton.setTitle("发送", for: .normal)
        }
    }
    
    /// 仅editType可用
    func updateItems(for mediaType: PHAssetMediaType) {
        guard type == .edit else { return }
        let flag = mediaType != .image
        typeButton.isHidden = flag
        originButton.isHidden = flag
    }
    
    var isEditable: Bool {
        set {
            guard type == .edit else { return }
            typeButton.isEnabled = newValue
        }
        get {
            guard type == .edit else { return false }
            return typeButton.isEnabled
        }
    }
    
    @objc private func shouldRespondTypeAction() {
        delegate?.selectBarDidRespondsTypeAction(self)
    }
    
    @objc private func shouldSend() {
        delegate?.selectBarShouldSendSelectedAssets(self)
    }
    
    @objc private func shouldUseOriginImage(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.selectBarDidChangeUseOriginalImageState?(self)
    }
    
    class XHPhotoSelectBarButton: UIButton {
        
        override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
            size.width += 5
            return size
        }
        
        override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
            var rect = super.imageRect(forContentRect: contentRect)
            rect.origin.x -= 2.5
            return rect
        }
        
        override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
            var rect = super.titleRect(forContentRect: contentRect)
            rect.origin.x += 2.5
            return rect
        }
        
    }
    
}

@objc fileprivate protocol XHPhotoSelectBarDelegate: NSObjectProtocol {
    
    func selectBarDidRespondsTypeAction(_ bar: XHPhotoSelectBar)
    
    func selectBarShouldSendSelectedAssets(_ bar: XHPhotoSelectBar)
    
    @objc optional func selectBarDidChangeUseOriginalImageState(_ bar: XHPhotoSelectBar)
    
}


class XHPhotoAsset: NSObject {
    
    private var asset: PHAsset
    
    var mediaType: PHAssetMediaType {
        return asset.mediaType
    }
    
    var duration: TimeInterval {
        return asset.duration
    }
    
    var originalSize: CGSize {
        return CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
    }
    
    lazy var durationDescription: String = {
        guard mediaType == .video else { return "" }
        let minite = Int(duration) / 60
        let section = Int(duration) % 60
        return String(format: "\(minite):%02d", section)
    }()
    
    init(asset: PHAsset) {
        self.asset = asset
        super.init()
    }
 
    fileprivate var isSelected: Bool = false
    
    fileprivate var selectedIndex: Int = 0
    
    fileprivate var selectable: Bool = true
    
    private(set) var thumbImage: UIImage?
    
    private(set) var image: UIImage?
    
    private var originRequestID: PHImageRequestID?
    
    private(set) var playerItem: AVPlayerItem?
    
    private var playerRequestID: PHImageRequestID?
    
    func fetchCoverImage(completion: @escaping (XHPhotoAsset)->Void) {
        if thumbImage != nil {
            completion(self)
            return
        }
        let width = (UIScreen.main.bounds.width - 5 * 5) / 4
        let height = CGFloat(asset.pixelHeight) / (CGFloat(asset.pixelWidth) / width)
        fetchImage(in: CGSize(width: width, height: height)) { [weak self](image) in
            if let weakSelf = self {
                weakSelf.thumbImage = image
                completion(weakSelf)
            }
        }
    }
    
    @discardableResult private func fetchImage(in size: CGSize,completion: @escaping (UIImage?)->Void) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .exact
        let scale = UIScreen.main.scale
        let realSize = CGSize(width: size.width * scale, height: size.height * scale)
        return PHImageManager.default().requestImage(for: asset, targetSize: realSize, contentMode: .aspectFill, options: options, resultHandler: { (image, _) in
            completion(image)
        })
    }
    
    func requestOriginalImage(completion:@escaping (UIImage?) -> Void) {
        if let image = self.image {
            completion(image)
            return
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        originRequestID = PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { [weak self](image, _) in
            self?.image = image
            completion(image)
        }
    }
    
    func cancelOriginRequest() {
        if let requestID = originRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        originRequestID = nil
    }
    
    func requestPlayerItem(completion:@escaping (AVPlayerItem?) -> Void) {
        guard asset.mediaType == .video else { return }
        if let item = self.playerItem {
            completion(item)
            return
        }
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        originRequestID = PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { [weak self](item, _) in
            self?.playerItem = item
            completion(item)
        }
    }
    
    func cancelVideoRequest() {
        if let requestID = playerRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }
        playerRequestID = nil
    }
    
    deinit {
        cancelOriginRequest()
        cancelVideoRequest()
    }
    
}

// MARK: - XHPhotoBrowseController
fileprivate class XHPhotoBrowseController: UIViewController {
    
    var isPeeking: Bool = false
    
    private var assets: [XHPhotoAsset]!
    
    private var currentIndex: Int = 0
    
    private lazy var selectedAssests: [XHPhotoAsset] = {
        var temp = assets.filter({ $0.isSelected })
        temp.sort(by: { $0.selectedIndex < $1.selectedIndex })
        return temp
    }()
    
    private var isChanged: Bool = false
    
    weak var delegate: XHPhotoBrowseControllerDelegate?
    
    var isUseOringinImage: Bool {
        set {
            selectedBar.isUseOringinImage = newValue
        }
        get {
            return selectedBar.isUseOringinImage
        }
    }
    
    func setAssets(_ assets: [XHPhotoAsset],index: Int) {
        self.assets = assets
        self.currentIndex = index
    }
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = UIScreen.main.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let temp = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        temp.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            temp.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        temp.register(XHPhotoBrowseCell.self, forCellWithReuseIdentifier: "cell")
        temp.isPagingEnabled = true
        temp.dataSource = self
        temp.delegate = self
        temp.isScrollEnabled = false
        return temp
    }()
    
    private lazy var selectedBar = XHPhotoSelectBar(type: .edit)
    
    private let selectNavigationBarLabel: UILabel = {
        let temp = UILabel()
        temp.font = UIFont.systemFont(ofSize: 15)
        temp.textColor = UIColor.white
        temp.textAlignment = .center
        temp.layer.masksToBounds = true
        return temp
    }()
    
    private let navigationBar = XHNavigationBar()
    
    private let indexBar = XHAssetIndexBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        view.addSubview(collectionView)
        view.addSubview(selectedBar)
        selectedBar.delegate = self
        selectedBar.translatesAutoresizingMaskIntoConstraints = false
        selectedBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        selectedBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        selectedBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        selectedBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -44).isActive = true
        selectedBar.updateItemsStatus(selectCount: selectedAssests.count)
        let currentAsset = assets[currentIndex]
        selectedBar.updateItems(for: currentAsset.mediaType)
        configureNavigationBar()
        view.addSubview(indexBar)
        indexBar.translatesAutoresizingMaskIntoConstraints = false
        indexBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        indexBar.bottomAnchor.constraint(equalTo: selectedBar.topAnchor).isActive = true
        indexBar.dataSource = self
        indexBar.delegate = self
        addGestureRecognizers()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !collectionView.isScrollEnabled {
            collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * collectionView.bounds.width, y: 0), animated: false)
            collectionView.isScrollEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func configureNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_back"), style: .plain, target: self, action: #selector(finishBrowsing))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let customView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 33, height: 44)))
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "sharecard_done"), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        customView.addSubview(button)
        button.frame = CGRect(x: 0, y: 5.5, width: 33, height: 33)
        button.addTarget(self, action: #selector(selectAsset), for: .touchUpInside)
        customView.addSubview(selectNavigationBarLabel)
        selectNavigationBarLabel.frame = CGRect(x: 3, y: 7, width: 30, height: 30)
        selectNavigationBarLabel.layer.cornerRadius = 15
        selectNavigationBarLabel.backgroundColor = UIColor.main
        selectNavigationBarLabel.isHidden = true
        let barItem = UIBarButtonItem(customView: customView)
        navigationBar.items = [leftBarButtonItem,spaceItem,barItem]
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBar.bottomAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor, constant: 44).isActive = true
        navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigationBar.barTintColor = UIColor(hex: 0x282b35, alpha: 0.8)
        updateNavigationRightItem()
    }
    
    private func updateNavigationRightItem() {
        let currentAsset = assets[currentIndex]
        if currentAsset.isSelected {
            selectNavigationBarLabel.text = "\(currentAsset.selectedIndex)"
        }
        selectNavigationBarLabel.isHidden = !currentAsset.isSelected
    }
    
    @objc private func finishBrowsing() {
        if isChanged {
            delegate?.browseControllerShouldPopBackWithChanges(self)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func selectAsset() {
        let asset = assets[currentIndex]
        if asset.isSelected {
            isChanged = true
            let currentIndex = selectedAssests.index(of: asset)!
            for index in currentIndex ..< selectedAssests.count {
                let asset = selectedAssests[index]
                asset.selectedIndex -= 1
            }
            asset.isSelected = false
            selectedAssests.remove(at: currentIndex)
            indexBar.deleteItems(at: [asset.selectedIndex])
            asset.selectedIndex = 0
            selectNavigationBarLabel.isHidden = true
            if selectedAssests.count == maxNumberOfSelectedItems - 1 {
                delegate?.browseControllerDidDropMaxNumberOfAssets(self)
            }
            selectedBar.updateItemsStatus(selectCount: selectedAssests.count)
        } else {
            if selectedAssests.count < maxNumberOfSelectedItems {
                isChanged = true
                asset.isSelected = true
                selectedAssests.append(asset)
                asset.selectedIndex = selectedAssests.count
                selectNavigationBarLabel.text = "\(selectedAssests.count)"
                selectNavigationBarLabel.isHidden = false
                selectNavigationBarLabel.shakeAnimation()
                if selectedAssests.count == maxNumberOfSelectedItems {
                    delegate?.browseControllerDidSelectMaxNumberOfAssets(self)
                }
                selectedBar.updateItemsStatus(selectCount: selectedAssests.count)
                indexBar.insertItems(at: [asset.selectedIndex - 1])
            } else {
                UIAlertController.showCannotSelectMoreAlert(from: self)
            }
        }
    }
    
    /// 添加相关手势，全局单击手势和拖拽手势
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        collectionView.addGestureRecognizer(tap)
    }
    
    private var isFront: Bool = false {
        didSet {
            guard isFront != oldValue else { return }
            if isFront {
                view.bringSubviewToFront(collectionView)
            } else {
                view.sendSubviewToBack(collectionView)
            }
        }
    }
    
    private var isPlaying: Bool = false
    
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let currentAsset = assets[currentIndex]
        if currentAsset.mediaType == .video {
            isPlaying = !isPlaying
            if isPlaying {
                print("开始播放")
            } else {
                print("停止播放")
            }
            isFront = isPlaying
        } else {
            isFront = !isFront
        }
    }
    
}

extension XHPhotoBrowseController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XHPhotoBrowseCell
        cell.asset = assets[indexPath.item]
        return cell
    }
}

extension XHPhotoBrowseController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        guard currentIndex != index else { return }
        var indexs = [Int]()
        let asset = assets[currentIndex]
        if asset.isSelected {
            indexs.append(asset.selectedIndex - 1)
        }
        currentIndex = index
        let currentAsset = assets[currentIndex]
        if currentAsset.isSelected {
            let index = currentAsset.selectedIndex - 1
            indexs.append(index)
            indexBar.scrollToItem(at: index)
        }
        if !indexs.isEmpty {
            indexBar.reloadItems(at: indexs)
        }
        updateNavigationRightItem()
        var enable = selectedAssests.count < maxNumberOfSelectedItems
        if !enable {
            enable = selectedAssests.contains(currentAsset)
        }
        selectedBar.isEditable = enable
    }
}

extension XHPhotoBrowseController: XHPhotoSelectBarDelegate {
    
    func selectBarDidRespondsTypeAction(_ bar: XHPhotoSelectBar) {
        let asset = assets[currentIndex]
        if let image = asset.image {
            let editController = XHImageEditController(image: image)
            editController.modalTransitionStyle = .crossDissolve
            present(editController, animated: true) {[weak self] in
                if let weakSelf = self {
                    weakSelf.collectionView.reloadItems(at: [IndexPath(item: weakSelf.currentIndex, section: 0)])
                }
            }
        }
    }
    
    func selectBarShouldSendSelectedAssets(_ bar: XHPhotoSelectBar) {
        if let navigationController = navigationController as? XHImagePickerController {
            if selectedAssests.isEmpty {
                let asset = assets[currentIndex]
                navigationController.didFinishPickingMediaAssets([asset])
            } else {
                navigationController.didFinishPickingMediaAssets(selectedAssests)
            }
        }
    }
    
    func selectBarDidChangeUseOriginalImageState(_ bar: XHPhotoSelectBar) {
        let asset = assets[currentIndex]
        guard !asset.isSelected else { return }
        selectAsset()
    }
    
}

extension XHPhotoBrowseController: XHAssetIndexBarDataSource {
    
    func numberOfItems(in indexBar: XHAssetIndexBar) -> Int {
        return selectedAssests.count
    }
    
    func indexBar(_ indexBar: XHAssetIndexBar, assetForItemAt index: Int) -> XHPhotoAsset {
        return selectedAssests[index]
    }
    
    func indexBar(_ indexBar: XHAssetIndexBar, isCurrentAssetForItemAt index: Int) -> Bool {
        let currentAsset = assets[currentIndex]
        return currentAsset == selectedAssests[index]
    }
    
}

extension XHPhotoBrowseController: XHAssetIndexBarDelegate {
    
    func indexBar(_ indexBar: XHAssetIndexBar, didSelectItemAt index: Int) {
        let asset = selectedAssests[index]
        let currentAsset = assets[currentIndex]
        guard asset != currentAsset else { return }
        var indexs = [index]
        if currentAsset.isSelected {
            indexs.append(currentAsset.selectedIndex - 1)
        }
        currentIndex = assets.index(of: asset)!
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * collectionView.bounds.width, y: 0), animated: true)
        updateNavigationRightItem()
        selectedBar.updateItems(for: asset.mediaType)
        indexBar.reloadItems(at: indexs)
    }
    
}

fileprivate protocol XHPhotoBrowseControllerDelegate: NSObjectProtocol {
    
    func browseControllerShouldPopBackWithChanges(_ controller: XHPhotoBrowseController)
    
    func browseControllerDidSelectMaxNumberOfAssets(_ controller: XHPhotoBrowseController)
    
    func browseControllerDidDropMaxNumberOfAssets(_ controller: XHPhotoBrowseController)
    
}

fileprivate class XHPhotoBrowseCell: UICollectionViewCell {
    
    private let imageView = XHZoomableImageView(frame: .zero)
    
    private let playView = UIImageView(image: #imageLiteral(resourceName: "moment_timeline_fold_playbtn"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.maximumZoomScale = 3
        if #available(iOS 11.0, *) {
            imageView.contentInsetAdjustmentBehavior = .never
        }
        contentView.addSubview(playView)
        playView.isHidden = true
        playView.translatesAutoresizingMaskIntoConstraints = false
        playView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        playView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var asset: XHPhotoAsset! {
        didSet {
            imageView.image = asset.thumbImage
            asset.requestOriginalImage { [weak self](image) in
                self?.imageView.image = image
            }
            if asset.mediaType == .video {
                playView.isHidden = false
                imageView.isUserInteractionEnabled = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        asset.cancelOriginRequest()
        imageView.zoomScale = imageView.minimumZoomScale
        imageView.isUserInteractionEnabled = true
        playView.isHidden = true
    }
    
    deinit {
        asset.cancelOriginRequest()
    }
    
}

fileprivate class XHAssetIndexBar: UIView {
    
    private let insetMargin: CGFloat = 13
    
    weak var dataSource: XHAssetIndexBarDataSource?
    
    weak var delegate: XHAssetIndexBarDelegate?
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsets(top: insetMargin, left: insetMargin, bottom: insetMargin, right: insetMargin)
        flowLayout.minimumLineSpacing = 10
        let temp = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        temp.backgroundColor = UIColor.clear
        temp.register(XHAssetIndexBarCell.self, forCellWithReuseIdentifier: "cell")
        temp.dataSource = self
        temp.delegate = self
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0x282b35, alpha: 0.8)
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.alwaysBounceHorizontal = true
        let shadowView = UIImageView()
        addSubview(shadowView)
        shadowView.backgroundColor = UIColor(hex: 0x393939)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        shadowView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        shadowView.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 87)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func reloadItems(at indexs: [Int]) {
        let indexPaths = indexs.map{ IndexPath(item: $0, section: 0) }
        collectionView.reloadItems(at: indexPaths)
        
    }
    
    func deleteItems(at indexs: [Int]) {
        let indexPaths = indexs.map{ IndexPath(item: $0, section: 0) }
        collectionView.deleteItems(at: indexPaths)
    }
    
    func insertItems(at indexs: [Int]) {
        let indexPaths = indexs.map{ IndexPath(item: $0, section: 0) }
        collectionView.insertItems(at: indexPaths)
    }
    
    func scrollToItem(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
}

extension XHAssetIndexBar: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataSource?.numberOfItems(in: self) ?? 0
        isHidden = count == 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XHAssetIndexBarCell
        cell.setAsset(dataSource?.indexBar(self, assetForItemAt: indexPath.item), isCurrent: dataSource?.indexBar(self, isCurrentAssetForItemAt: indexPath.item) ?? false)
        return cell
    }
    
}

extension XHAssetIndexBar: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.indexBar(self, didSelectItemAt: indexPath.item)
        if let cell = collectionView.cellForItem(at: indexPath) {
            var point = collectionView.contentOffset
            if cell.frame.maxX > collectionView.contentOffset.x + collectionView.bounds.width {
                point.x = cell.frame.maxX - collectionView.bounds.width
            } else if cell.frame.minX < collectionView.contentOffset.x {
                point.x = cell.frame.minX
            }
            guard point != collectionView.contentOffset else { return }
            collectionView.setContentOffset(point, animated: true)
        }
    }
    
}

extension XHAssetIndexBar: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - insetMargin * 2
        return CGSize(width: height, height: height)
    }
    
}

fileprivate protocol XHAssetIndexBarDataSource: NSObjectProtocol {
    
    func numberOfItems(in indexBar: XHAssetIndexBar) -> Int
    
    func indexBar(_ indexBar: XHAssetIndexBar, assetForItemAt index: Int) -> XHPhotoAsset
    
    func indexBar(_ indexBar: XHAssetIndexBar, isCurrentAssetForItemAt index: Int) -> Bool
    
}

fileprivate protocol XHAssetIndexBarDelegate: NSObjectProtocol {
    
    func indexBar(_ indexBar: XHAssetIndexBar, didSelectItemAt index: Int)
    
}

fileprivate class XHAssetIndexBarCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAsset(_ asset: XHPhotoAsset?,isCurrent: Bool) {
        imageView.image = asset?.thumbImage
        guard isCurrent else { return }
        imageView.layer.borderColor = UIColor.main.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = nil
    }
    
}

fileprivate extension UIAlertController {
    
    static func showCannotSelectMoreAlert(from viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: "你最多只能选择9张照片", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "我知道了", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
}


