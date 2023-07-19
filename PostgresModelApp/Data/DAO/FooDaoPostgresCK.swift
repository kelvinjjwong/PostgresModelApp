//
//  FooDaoPostgresCK.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation
import PostgresClientKit

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
}
