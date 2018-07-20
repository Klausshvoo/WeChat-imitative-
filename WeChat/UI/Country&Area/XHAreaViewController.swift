//
//  XHAreaViewController.swift
//  WeChat
//
//  Created by Li on 2018/7/12.
//  Copyright © 2018年 Li. All rights reserved.
//

import UIKit

class XHAreaViewController: UIViewController {
    
    var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    let searchController = UISearchController(searchResultsController: UIViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        view.addSubview(tableView)
        searchController.searchBar.placeholder = "搜索"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.barTintColor = UIColor.cellHL
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive  = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.tableHeaderView = searchController.searchBar
        configureNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
           let searchBar = searchController.searchBar
            searchBar.setPositionAdjustment(UIOffset(horizontal: 100, vertical: 0), for: .search)
        }
    }
    
    private func configureNavigationBar() {
        title = "选择国家和地区"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "barbuttonicon_back"), title: "返回", target: self, action: #selector(back))
    }
    
    @objc private func back() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

struct XHArea: Codable {
    
    var name: String
    
    var areaCode: String
    
    init?(_ areaCode: String) {
        return nil
    }
    
    private init (name: String,areaCode: String) {
        self.areaCode = areaCode
        self.name = name
    }
    
    static func allAreas() -> [XHArea] {
        let database = XHDatabase.configuration
        database.open()
        var temp = [XHArea]()
        if let set = database.excuteQuery(sql: "select * from AreaCode") {
            while set.next() {
                let name = set.string(forColumn: "name")!
                let areaCode = set.string(forColumn: "areaCode")!
                let area = XHArea(name: name, areaCode: areaCode)
                temp.append(area)
            }
            set.close()
        }
        database.close()
        return temp
    }
    
}
