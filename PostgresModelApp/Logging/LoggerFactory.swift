//
//  LoggerFactory.swift
//  PostgresModelApp
//
//  Created by Kelvin Wong on 2023/7/19.
//

import Foundation

enum LogType: String{
    
    static func iconOfType(_ logType:LogType) -> String {
        switch logType {
        case LogType.error:
            return "📕"
        case LogType.warning:
            return "📙"
        case LogType.debug:
            return "📓"
        case LogType.todo:
            return "⚠️"
        case LogType.trace:
            return "🐢"
        case LogType.performance:
            return "🕘"
        default:
            return "📗"
        }
    }
    
    case error
    case warning
    case info
    case debug
    case todo
    case trace
    case performance
}

protocol LogWriter {
    func write(message: String)
}

class Logger {
    
    fileprivate var logMessageBuilder:LogMessageBuilder
    private var displayTypes:[LogType] = [.info, .error, .todo, .warning] // .debug not included by default
    
    init(category:String, subCategory:String, includeTypes:[LogType] = [], excludeTypes:[LogType] = []) {
        self.logMessageBuilder = LogMessageBuilder(category: category, subCategory: subCategory)
        
        if !includeTypes.isEmpty {
            for t in includeTypes {
                if let _ = self.displayTypes.firstIndex(of: t) {
                    // continue
                }else{
                    self.displayTypes.append(t)
                }
            }
        }
        
        if !excludeTypes.isEmpty {
            let defaultTypes:Set<LogType> = Set(self.displayTypes)
            let removeTypes:Set<LogType> = Set(excludeTypes)
            self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
        }
    }
    
    func timecost(_ message:String, fromDate:Date) {
        guard self.displayTypes.contains(.performance) else {return}
        let msg = self.logMessageBuilder.build(logType: .performance, message: "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds", error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ message:String) {
        guard self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:String) {
        guard self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for logger in logWriters {
            logger.write(message: msg)
        }
    }
    
    func log(_ message:Int) {
        guard self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Int) {
        guard self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ message:Double) {
        guard self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Double) {
        guard self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for logger in logWriters {
            logger.write(message: msg)
        }
    }
    
    func log(_ message:Float) {
        guard self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    func log(_ logType:LogType, _ message:Float) {
        guard self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ message:Any) {
        guard self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Any) {
        guard self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for logger in logWriters {
            logger.write(message: msg)
        }
    }
    
    func log(_ message:Error) {
        guard self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: message)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Error) {
        guard self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ message:String, _ error:Error) {
        guard self.displayTypes.contains(.info) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:String, _ error:Error) {
        guard self.displayTypes.contains(logType) else {return}
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error)
        let logWriters = LoggerFactory.writers
        for writer in logWriters {
            writer.write(message: msg)
        }
    }
}

class LoggerFactory {
    
    fileprivate static var writers:[LogWriter] = []
    
    static func append(logWriter:LogWriter) {
        Self.writers.append(logWriter)
    }
    
    static func get(category:String, subCategory:String = "", includeTypes:[LogType] = [], excludeTypes:[LogType] = []) -> Logger {
        return Logger(category: category, subCategory: subCategory)
    }
    
}
