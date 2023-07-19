//
//  FooDao.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

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
}
