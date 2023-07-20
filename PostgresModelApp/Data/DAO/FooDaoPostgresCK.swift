//
//  FooDaoPostgresCK.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation
import PostgresClientKit
import LoggerFactory

class FooDaoPostgresCK : FooDaoInterface {
    
    let logger = LoggerFactory.get(category: "FooDaoPostgresCK")
    
    func getFoo(id: Int) -> Foo? {
        if let db = PostgresDB.connect() {
            return Foo.fetchOne(db, parameters: ["id" : id])
        }
        return nil
    }
    
    func getFoos() -> [Foo] {
        if let db = PostgresDB.connect() {
            return Foo.fetchAll(db)
        }
        return []
    }
    
    func updateFoo(id:Int, name:String?, age:Int?) {
        if let db = PostgresDB.connect() {
            if let foo = Foo.fetchOne(db, parameters: ["id": id]) {
                foo.name = name
                foo.age = age
                foo.save(db)
            }
        }
    }
    
    func insertFoo(name:String?, age:Int?) {
        if let db = PostgresDB.connect() {
            let foo = Foo()
            foo.name = name
            foo.age = age
            foo.save(db)
        }
    }
    
    func queryFoo(name:String) -> [Foo] {
        if let db = PostgresDB.connect() {
            return Foo.fetchAll(db, parameters: ["name": name], orderBy: "age")
        }
        return []
    }
}
