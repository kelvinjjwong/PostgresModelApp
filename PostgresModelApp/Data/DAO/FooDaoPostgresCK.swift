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
    
    func versionCheck() {
        if let db = PostgresDB.connect() {
            let migrator = DatabaseVersionMigrator(sqlGenerator: PostgresSchemaSQLGenerator(dropBeforeCreate: true), sqlExecutor: db)
            
            migrator.version("v1") { db in
                try db.create(table: "foo", body: { t in
                    t.column("id", .serial).primaryKey().unique().notNull()
                    t.column("name", .text)
                    t.column("age", .integer)
                })
                
                // INIT DATA
                FooDao.default.insertFoo(name: "Tom", age: 23)
                FooDao.default.insertFoo(name: "Daisy", age: 17)
                FooDao.default.insertFoo(name: "Helen", age: 9)
                
                // QUERY ALL
                let foos = FooDao.default.getFoos()
                for foo in foos {
                    print("inserted record: \(foo.id) \(foo.age) \(foo.name)")
                }
            }
            
            migrator.version("v2") { db in
                try db.create(table: "bar", body: { t in
                    t.column("id", .serial).primaryKey().unique().notNull()
                    t.column("name", .text)
                    t.column("age", .integer)
                })
            }
            
            
            do {
                try migrator.migrate(cleanVersions: true)
            }catch{
                self.logger.log(error)
            }
        }
    }
}
