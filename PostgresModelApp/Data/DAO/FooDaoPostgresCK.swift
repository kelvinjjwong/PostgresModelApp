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
    
    func versionCheck(cleanAll: Bool) {
        if let db = PostgresDB.connect() {
            let migrator = DatabaseVersionMigrator(sqlGenerator: PostgresSchemaSQLGenerator(dropBeforeCreate: cleanAll), sqlExecutor: db)
            
            // CREATE TABLE
            migrator.version("v1") { db in
                try db.create(table: "foo", body: { t in
                    t.column("id", .serial).primaryKey().unique().notNull()
                    t.column("name", .text)
                    t.column("age", .integer)
                    t.column("lastUpdate", .datetime)
                })
                
                // CREATE TRIGGER to add update time
                try db.create(trigger: "tg_foo_modify_time_on_insert",
                              when: .before,
                              action: .insert,
                              on: "foo",
                              level: .forEachRow,
                              function: "tg_foo_modify_time_on_insert",
                              body: """
NEW."lastUpdate"=NOW();
RETURN NEW;
"""
                )
                
                try db.create(trigger: "tg_foo_modify_time_on_update",
                              when: .before,
                              action: .update,
                              on: "foo",
                              level: .forEachRow,
                              function: "tg_foo_modify_time_on_update",
                              body: """
NEW."lastUpdate"=NOW();
RETURN NEW;
""")
                
                // INSERT INITIAL DATA
                FooDao.default.insertFoo(name: "Tom", age: 23)
                FooDao.default.insertFoo(name: "Daisy", age: 17)
                FooDao.default.insertFoo(name: "Helen", age: 9)
                
                // QUERY ALL
                let foos = FooDao.default.getFoos()
                for foo in foos {
                    print("inserted record: \(foo.id) \(foo.age) \(foo.name) \(foo.lastUpdate)")
                }
                
                // let time changes
                print("sleeping ...")
                sleep(2)
                
                // UPDATE RECORD
                let records = FooDao.default.queryFoo(name: "Tom")
                if !records.isEmpty {
                    let tom = records[0]
                    if let id = tom.id {
                        FooDao.default.updateFoo(id: id, name: "Tom", age: 34)
                        
                        if let updated_tom = FooDao.default.getFoo(id: id) {
                            print("updated record: \(updated_tom.id) \(updated_tom.age) \(updated_tom.name) \(updated_tom.lastUpdate)")
                        }
                    }
                }
            }
            
            // CREATE ANOTHER TABLE
            migrator.version("v2") { db in
                try db.create(table: "bar", body: { t in
                    t.column("id", .serial).primaryKey().unique().notNull()
                    t.column("name", .text)
                    t.column("age", .integer)
                })
            }
            
            // ALTER TABLE
            migrator.version("v3") { db in
                try db.alter(table: "bar", body: { t in
                    t.add("city", .text).indexed("idx_bar_city") // CREATE INDEX
                    t.add("birth", .date)
                    t.add("dept", .text).indexed("idx_bar_dept")    // CREATE MULTICOLUMN INDEX
                    t.add("subDept", .text).indexed("idx_bar_dept")
                })
            }
            
            
            do {
                try migrator.migrate(cleanVersions: cleanAll)
            }catch{
                self.logger.log(error)
            }
        }
    }
}
