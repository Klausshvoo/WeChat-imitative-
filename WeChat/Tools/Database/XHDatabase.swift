//
//  XHDatabase.swift
//  WeChat
//
//  Created by Li on 2018/7/11.
//  Copyright © 2018年 Li. All rights reserved.
//

import FMDB

class XHDatabase: NSObject {
    
    /// 主要存储一些通用设置，如国家/地区，语言
    static let configuration = XHDatabase(path: NSHomeDirectory().appending("/Documents/configuration.sqlite"))
    
    static let message = XHDatabase(path: NSHomeDirectory().appending("/Documents/messages.sqlite"))
    
    static let relation = XHDatabase(path: NSHomeDirectory().appending("/Documents/relations.sqlite"))
    
    /// 存储路径，readonly
    private(set) var path: String
    
    /// 数据库操作，readonly
    private(set) var db: FMDatabase
    
    init(path: String) {
        self.path = path
        print(path)
        db = FMDatabase(path: path)
    }
    
    /// 开启数据库
    @discardableResult func open() -> Bool {
        return db.open()
    }
    
    /// 关闭数据库
    @discardableResult func close() -> Bool {
        return db.close()
    }
    
    /// 执行更新类sql语句,若返回false表示执行失败，将自动回滚本次更新
    @discardableResult func excuteUpdate(sqls: String...) -> Bool {
        objc_sync_enter(self)
        var flag: Bool = true
        db.beginTransaction()
        for sql in sqls {
            do {
                try db.executeUpdate(sql, values: nil)
            } catch {
                flag = true
                break
            }
        }
        if !flag {
            db.rollback()
        } else {
            db.commit()
        }
        objc_sync_exit(self)
        return flag
    }
    
    /// 执行查询类sql语句，若执行失败，将不会返回结果集
    func excuteQuery(sql: String) -> FMResultSet? {
        objc_sync_enter(self)
        let set = try? db.executeQuery(sql, values: nil)
        objc_sync_exit(self)
        return set
    }
    
}
