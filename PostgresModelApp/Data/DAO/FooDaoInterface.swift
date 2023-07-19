//
//  FooDaoInterface.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Foundation


protocol FooDaoInterface {
    
    func getFoo(id:Int) -> Foo?
    
    func getFoos() -> [Foo]
}
