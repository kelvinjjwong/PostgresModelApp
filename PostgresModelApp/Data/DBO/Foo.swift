//
//  Foo.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation

public final class Foo : Codable {
    
    var id:Int = 0
    var age:Int?
    var name:String?
    
    public init() {
        
    }
    
    
}


extension Foo : PostgresRecord {
    public func postgresTable() -> String {
        return "foo"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
