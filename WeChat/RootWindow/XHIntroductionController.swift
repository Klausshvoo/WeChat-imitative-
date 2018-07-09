//
//  XHIntroductionController.swift
//  WeChat
//
//  Created by Li on 2018/7/9.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHIntroductionController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    private var dataArr: [String] = []
    
    private let button = UIButton(type: .custom)
    
    weak var delegate: XHIntroductionControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bounds = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = bounds.size
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.background
        collectionView.dataSource = self
        collectionView.register(XHIntroductionCollectionCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension XHIntroductionController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! XHIntroductionCollectionCell
        cell.image = UIImage(named: dataArr[indexPath.item])
        return cell
    }
    
}

fileprivate class XHIntroductionCollectionCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
}

protocol XHIntroductionControllerDelegate: NSObjectProtocol {
    
    func introductionControllerDidEndIntroduce(_ controller: XHIntroductionController)
    
}
