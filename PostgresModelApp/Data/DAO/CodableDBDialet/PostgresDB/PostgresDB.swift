//
//  PostgresSQLStatementExecutor.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/20.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

public class PostgresDB : DBExecutor {
    
    let logger = LoggerFactory.get(category: "DB", subCategory: "PostgresDB", includeTypes: [])
    
    private let postgresConfig: ConnectionConfiguration
    
    var schema:String = "public"
    
    private static var database = ""
    private static var host = ""
    private static var port = 0
    private static var user = ""
    private static var password:String? = nil
    private static var ssl = false
    
    public static func connect() -> PostgresDB? {
        if Self.database == "" || Self.host == "" {
            return nil
        }
        return PostgresDB(database: Self.database, host: Self.host, port: Self.port, user: Self.user, password: Self.password, ssl: Self.ssl)
    }
    
    public static func connect(database:String, host:String = "127.0.0.1", port:Int = 5432, user:String = "postgres", password:String? = nil, ssl:Bool = false) -> PostgresDB {
        Self.database = database
        Self.host = host
        Self.port = port
        Self.user = user
        Self.password = password
        Self.ssl = ssl
        return PostgresDB(database: database, host: host, port: port, user: user, password: password, ssl: ssl)
    }
    
    public init(database:String, host:String = "127.0.0.1", port:Int = 5432, user:String = "postgres", password:String? = nil, ssl:Bool = false) {
        self.logger.log("connecting: \(user)@\(host):\(port)/\(database)")
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = host
        configuration.port = port
        configuration.database = database
        configuration.user = user
        if let psw = password {
            configuration.credential = .cleartextPassword(password: psw)
        }else{
            configuration.credential = .trust
        }
        configuration.ssl = ssl
        self.postgresConfig = configuration
    }
    public func execute(sql: String) throws {
        self.logger.log(.trace, " >>> execute sql: \(sql)")
        let statement = SQLStatement(sql: sql)
        try self.execute(statement: statement)
    }
    
    public func execute(sql: String, parameterValues:[PostgresValueConvertible?]) throws {
        self.logger.log(.trace, " >>> execute sql: \(sql)")
        let statement = SQLStatement(sql: sql)
        statement.arguments = parameterValues
        try self.execute(statement: statement)
    }
    
    public func execute(statement: SQLStatement) throws {

        let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
        defer { connection.close() }
        
        let stmt = try connection.prepareStatement(text: statement.sql)
        defer { stmt.close() }
        
        if statement.arguments.count > 0 {
            let _ = try stmt.execute(parameterValues: statement.arguments)
        }else{
            let _ = try stmt.execute()
        }
    }
    
    public func delete<T:Codable & EncodableDBRecord>(object:T, table:String, primaryKeys:[String]) {
        var _sql = ""
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let generator = PostgreSQLStatementGenerator(table: table, record: object)
            let statement = generator.deleteStatement(keyColumns: primaryKeys)
            _sql = statement.sql
            self.logger.log(.trace, " >>> execute sql: \(_sql)")
            try self.execute(statement: statement)
        }catch{
            self.logger.log(.error, "Error at PostgresDB.delete(object:table:primaryKeys)")
            self.logger.log(.error, "Error at sql: \(_sql)", error)
//            self.logger.log(error)
        }
    }
    
    public func save<T:Codable & EncodableDBRecord>(object:T, table:String, primaryKeys:[String], autofillColumns:[String]) {
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let generator = PostgreSQLStatementGenerator(table: table, record: object)
            let existsStatement = generator.existsStatement(keyColumns: primaryKeys)
            self.logger.log(.debug, "[save][ifexists] >>> execute sql: \(existsStatement.sql) , parameters: \(existsStatement.arguments)")
            let existsStmt = try connection.prepareStatement(text: existsStatement.sql)
            defer { existsStmt.close() }
            
            let existsCursor = try existsStmt.execute(parameterValues: existsStatement.arguments)
            defer { existsCursor.close() }
            
            var exists = false
            for row in existsCursor {
                let columns = try row.get().columns
                let flag = try columns[0].int() // FIXME: should load column by name rather by initial-ordered-index
                if flag == 1 {
                    exists = true
                }
            }
            
            if exists {
            
                let statement = generator.updateStatement(keyColumns: primaryKeys, autofillColumns: autofillColumns)
                self.logger.log(.debug, "[save][update] >>> execute sql: \(statement.sql)")
                let stmt = try connection.prepareStatement(text: statement.sql)
                defer { stmt.close() }
                
                let _ = try stmt.execute(parameterValues: statement.arguments)
            } else {
                let statement = generator.insertStatement(autofillColumns: autofillColumns)
                self.logger.log(.debug, "[save][insert] >>> execute sql: \(statement.sql)")
                let stmt = try connection.prepareStatement(text: statement.sql)
                defer { stmt.close() }
                
                let _ = try stmt.execute(parameterValues: statement.arguments)
            }

        } catch {
            self.logger.log(.error, "[save] Error at PostgresDB.save(object:table:primaryKeys)", error)
        }
        
    }
    
    public func query<T:Codable & EncodableDBRecord>(object:T, table:String, sql:String, values:[PostgresValueConvertible?] = [], offset:Int? = nil, limit:Int? = nil) -> [T] {
        
        var _sql = ""
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let _ = PostgreSQLStatementGenerator(table: table, record: object)
//            let columnNames = generator.persistenceContainer.columns
            
            var pagination = ""
            if let offset = offset, let limit = limit {
                pagination = "OFFSET \(offset) LIMIT \(limit)"
                
            }
            _sql = "\(sql) \(pagination)"
            
            self.logger.log(.trace, " >>> query sql: \(_sql)")
            
            let stmt = try connection.prepareStatement(text: "\(_sql)")
            defer { stmt.close() }

            let cursor = try stmt.execute(parameterValues: values)
            defer { cursor.close() }

            var result:[T] = []
            for row in cursor {
                let columns = try row.get().columns
                let row = PostgresRow.read(object, types: [], values: columns) // PostgresRow(columnNames: columnNames, values: columns)
                row.table = table
                if let obj:T = try PostgresRowDecoder().decodeIfPresent(from: row) {
                    result.append(obj)
                }
            }
            return result
        } catch {
            self.logger.log(.error, "Error at PostgresDB.query(object:table:sql:values:offset:limit) -> [T]")
            self.logger.log(.error, "Error at sql: \(_sql)", error)
//            self.logger.log(error) // better error handling goes here
//            if "\(error)".contains("Host is down") {
//
//            }

            return []
        }
    }
    
    public func query<T:Codable & EncodableDBRecord>(object:T, table:String, where whereSQL:String, orderBy:String = "", values:[PostgresValueConvertible?] = [], offset:Int? = nil, limit:Int? = nil) -> [T] {
        var _sql = ""
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let generator = PostgreSQLStatementGenerator(table: table, record: object)
            let statement = generator.selectStatement(where: whereSQL, orderBy: orderBy, values: values)
//            let columnNames = generator.persistenceContainer.columns
            
            var pagination = ""
            if let offset = offset, let limit = limit {
                pagination = "OFFSET \(offset) LIMIT \(limit)"
                
            }
            
            _sql = "\(statement.sql) \(pagination)"
            
            self.logger.log(.trace, " >>> query sql: \(_sql)")
            
            let stmt = try connection.prepareStatement(text: "\(_sql)")
            defer { stmt.close() }

            let cursor = try stmt.execute(parameterValues: values)
            defer { cursor.close() }

            var result:[T] = []
            for row in cursor {
                let columns = try row.get().columns
                let row = PostgresRow.read(object, types: [], values: columns) // PostgresRow(columnNames: columnNames, values: columns)
                row.table = table
                if let obj:T = try PostgresRowDecoder().decodeIfPresent(from: row) {
                    result.append(obj)
                }
            }
            return result
        } catch {
            self.logger.log(.error, "Error at PostgresDB.query(object:table:where:orderBy:values:offset:limit) -> [T]")
            self.logger.log(.error, "Error at sql: \(_sql)", error)
//            self.logger.log(error) // better error handling goes here

            return []
        }
    }
    
    public func query<T:Codable & EncodableDBRecord>(object:T, table:String, parameters:[String:PostgresValueConvertible?] = [:], orderBy:String = "") -> [T] {
        var _sql = ""
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let keyColumns:[String] = Array(parameters.keys)
            let values:[PostgresValueConvertible?] = Array(parameters.values)
            
            let generator = PostgreSQLStatementGenerator(table: table, record: object)
            let columnNames = generator.persistenceContainer.columns
            let joinedColumnNames = columnNames.joined(separator: ",")
            let statement = generator.selectStatement(columns: joinedColumnNames, keyColumns: keyColumns, orderBy: orderBy)
            
            _sql = statement.sql
            
            self.logger.log(.trace, " >>> query sql: \(_sql)")
            
            let stmt = try connection.prepareStatement(text: _sql)
            defer { stmt.close() }

            let cursor = try stmt.execute(parameterValues: values)
            defer { cursor.close() }

            var result:[T] = []
            for row in cursor {
                let columns = try row.get().columns
                let row = PostgresRow.read(object, types: [], values: columns) //PostgresRow(columnNames: columnNames, values: columns)
                row.table = table
                if let obj:T = try PostgresRowDecoder().decodeIfPresent(from: row) {
                    result.append(obj)
                }
            }
            return result
        } catch {
            self.logger.log(.error, "Error at PostgresDB.query(object:table:parameters:orderBy) -> [T]")
            self.logger.log(.error, "Error at sql: \(_sql)", error)
//            self.logger.log(error) // better error handling goes here

            return []
        }
    }
    
    public func queryOne<T:Codable & EncodableDBRecord>(object:T, table:String, where whereSQL:String, orderBy:String = "", values:[PostgresValueConvertible?] = []) -> T? {
        let list = self.query(object: object, table: table, where: whereSQL, orderBy: orderBy, values: values)
        if list.count > 0 {
            return list[0]
        }else{
            return nil
        }
    }
    
    public func queryOne<T:Codable & EncodableDBRecord>(object:T, table:String, parameters:[String:PostgresValueConvertible?] = [:]) -> T? {
        let list = self.query(object: object, table: table, parameters: parameters)
        if list.count > 0 {
            return list[0]
        }else{
            return nil
        }
    }
    
    public func queryOne<T:Codable & EncodableDBRecord>(object:T, table:String, sql:String, values:[PostgresValueConvertible?] = []) -> T? {
        let list = self.query(object: object, table: table, sql: sql, values: values)
        if list.count > 0 {
            return list[0]
        }else{
            return nil
        }
    }
    
    public func count(sql:String) -> Int {
        return self.count(sql: sql, parameterValues: [])
    }
    
    public func count(sql:String, parameterValues: [PostgresValueConvertible?]) -> Int {
        self.logger.log(.trace, " >>> count sql: \(sql)")
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            //self.logger.log(">> count sql: \(sql)")
            let stmt = try connection.prepareStatement(text: sql)
            defer { stmt.close() }

            let cursor = try stmt.execute(parameterValues: parameterValues)
            defer { cursor.close() }

            var result:Int = 0
            if let next = cursor.next() {
                let columns = try next.get().columns
                result = try columns[0].int()
            }
            return result
        } catch {
            self.logger.log(.error, "Error at PostgresDB.count(sql:parameterValues)")
            self.logger.log(.error, "Error sql: \(sql)", error)
//            self.logger.log(error) // better error handling goes here

            return -1
        }
    }
    
    public func count<T:Codable & EncodableDBRecord>(object:T, table:String, parameters:[String:PostgresValueConvertible?] = [:]) -> Int {
        var _sql = ""
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let keyColumns:[String] = Array(parameters.keys)
            let values:[PostgresValueConvertible?] = Array(parameters.values)
            
            let generator = PostgreSQLStatementGenerator(table: table, record: object)
            let statement = generator.countStatement(keyColumns: keyColumns)
            //let columnNames = generator.persistenceContainer.columns
            
            //self.logger.log(">> count sql: \(statement.sql)")
            let stmt = try connection.prepareStatement(text: statement.sql)
            _sql = statement.sql
            defer { stmt.close() }

            let cursor = try stmt.execute(parameterValues: values)
            defer { cursor.close() }

            var result:Int = 0
            if let next = cursor.next() {
                let columns = try next.get().columns
                result = try columns[0].int()
            }
            return result
        } catch {
            self.logger.log(.error, "Error at PostgresDB.count(object:table:parameters)")
            self.logger.log(.error, "Error at sql: \(_sql)", error)
//            self.logger.log(error) // better error handling goes here

            return -1
        }
    }
    
    public func count<T:Codable & EncodableDBRecord>(object:T, table:String, where whereSQL:String, values:[PostgresValueConvertible?] = []) -> Int {
        var _sql = ""
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let generator = PostgreSQLStatementGenerator(table: table, record: object)
            let statement = generator.countStatement(where: whereSQL, values: values)
            //let columnNames = generator.persistenceContainer.columns
            
            _sql = statement.sql
//            self.logger.log(">> count sql: \(statement.sql)")
            let stmt = try connection.prepareStatement(text: statement.sql)
            defer { stmt.close() }

            let cursor = try stmt.execute(parameterValues: values)
            defer { cursor.close() }

            var result:Int = 0
            if let next = cursor.next() {
                let columns = try next.get().columns
                result = try columns[0].int()
            }
            return result
        } catch {
            self.logger.log(.error, "Error at PostgresDB.count(object:table:where:values)")
            self.logger.log(.error, "Error at sql: \(_sql)", error)
//            self.logger.log(error) // better error handling goes here

            return -1
        }
    }
    
    public func queryTableInfo(table:String, schema:String = "public") -> TableInfo {
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let generator = PostgreSQLStatementGenerator(table: "columns", record: PostgresColumnInfo())
            let statement = generator.selectStatement(columns: "column_name,data_type,is_nullable,is_identity,character_maximum_length,numeric_precision,numeric_precision_radix",
                                                      keyColumns: ["table_schema", "table_name"],
                                                      schema: "information_schema")
            let columnNames = generator.persistenceContainer.columns
            
            let stmt = try connection.prepareStatement(text: statement.sql)
            defer { stmt.close() }

            let cursor = try stmt.execute(parameterValues: [schema, table])
            defer { cursor.close() }

            
            let tableInfo = TableInfo(table)
            for row in cursor {
                let columns = try row.get().columns
                let row = PostgresRow(columnNames: columnNames, values: columns)
                row.table = table
                if let col:PostgresColumnInfo = try PostgresRowDecoder().decodeIfPresent(from: row) {
                    tableInfo.add(column: col)
                }
            }
            
            return tableInfo
        } catch {
            self.logger.log(.error, "Error at PostgresDB.queryTableInfo", error)
//            self.logger.log(error) // better error handling goes here
            return TableInfo(table)
        }
    }
    
    
    public func queryTableInfos(schema:String = "public") -> [TableInfo] {
        var tables:[TableInfo] =  []
        do {
            let connection = try PostgresClientKit.Connection(configuration: self.postgresConfig)
            defer { connection.close() }
            
            let stmt = try connection.prepareStatement(text: "SELECT table_name FROM information_schema.tables WHERE table_schema=$1")
            defer { stmt.close() }

            let cursorTable = try stmt.execute(parameterValues: [schema])
            defer { cursorTable.close() }

            for row in cursorTable {
                let columns = try row.get().columns
                let table = try columns[0].string()
                let tableInfo = TableInfo(table)
                tables.append(tableInfo)
            }
            
            for table in tables {
                let generator = PostgreSQLStatementGenerator(table: "columns", record: PostgresColumnInfo())
                let statement = generator.selectStatement(columns: "column_name,data_type,is_nullable,is_identity,character_maximum_length,numeric_precision,numeric_precision_radix",
                                                          keyColumns: ["table_schema", "table_name"],
                                                          schema: "information_schema")
                let columnNames = generator.persistenceContainer.columns
                
                let stmt = try connection.prepareStatement(text: statement.sql)
                defer { stmt.close() }

                let cursor = try stmt.execute(parameterValues: [schema, table.name])
                defer { cursor.close() }

                
                for row in cursor {
                    let columns = try row.get().columns
                    let row = PostgresRow(columnNames: columnNames, values: columns)
                    row.table = table.name
                    if let col:PostgresColumnInfo = try PostgresRowDecoder().decodeIfPresent(from: row) {
                        table.add(column: col)
                    }
                }
            }
            
        } catch {
            self.logger.log(.error, error) // better error handling goes here
        }
        return tables
    }
}
