//
//  FooDao.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation
import LoggerFactory

public final class FooDao {
    
    let logger = LoggerFactory.get(category: "FooDao")
    
    private let impl:FooDaoInterface
    
    init(_ impl:FooDaoInterface) {
        self.impl = impl
    }
    
    static var `default`:FooDao {
        return FooDao(FooDaoPostgresCK())
    }
    
    func getFoo(id:Int) -> Foo? {
        return self.impl.getFoo(id: id)
    }
    
    func getFoos() -> [Foo] {
        return self.impl.getFoos()
    }
    
    func updateFoo(id:Int, name:String?, age:Int?) {
        self.impl.updateFoo(id: id, name: name, age: age)
    }
    
    func insertFoo(name:String?, age:Int?) {
        self.impl.insertFoo(name: name, age: age)
    }
    
    func queryFoo(name:String) -> [Foo] {
        return self.impl.queryFoo(name: name)
    }
    
    func versionCheck() {
        return self.impl.versionCheck()
    }
}
