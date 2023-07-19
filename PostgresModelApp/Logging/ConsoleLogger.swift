//
//  ConsoleLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/11.
//  Copyright © 2021 nonamecat. All rights reserved.
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

protocol LogMessageBuilderInterface {
    func build(logType:LogType, message:String, error:Error?) -> String
    func build(logType:LogType, message:Int, error:Error?) -> String
    func build(logType:LogType, message:Double, error:Error?) -> String
    func build(logType:LogType, message:Float, error:Error?) -> String
    func build(logType:LogType, message:Any, error:Error?) -> String
    func build(logType:LogType, error:Error) -> String
}

class LogMessageBuilder : LogMessageBuilderInterface {
    
    private let dtFormatter = ISO8601DateFormatter()
    
    private var category:String = ""
    private var subCategory:String = ""
    
    init(category:String, subCategory:String) {
        self.category = category
        self.subCategory = subCategory
    }
    
    fileprivate func prefix(category:String, subCategory:String) -> String {
        if subCategory == "" {
            return "\(self.dtFormatter.string(from: Date())) [\(category)]"
        }else{
            return "\(self.dtFormatter.string(from: Date())) [\(category)][\(subCategory)]"
        }
    }
    
    func build(logType:LogType, message:String, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    func build(logType:LogType, message:Int, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    func build(logType:LogType, message:Double, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    func build(logType:LogType, message:Float, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    func build(logType:LogType, message:Any, error:Error?) -> String {
        if let error = error {
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message) - \(error)"
        }else{
            return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(message)"
        }
    }
    
    func build(logType:LogType, error:Error) -> String {
        return "\(LogType.iconOfType(LogType.info)) \(self.prefix(category: category, subCategory: subCategory)) \(error)"
    }
}

class LogDispatcher {
    
    fileprivate var logMessageBuilder:LogMessageBuilder
    fileprivate var loggers:[LogWriter]
    
    init(category:String, subCategory:String, loggers: [LogWriter]) {
        self.logMessageBuilder = LogMessageBuilder(category: category, subCategory: subCategory)
        self.loggers = loggers
    }
    
    func timecost(_ message:String, fromDate:Date) {
        let msg = self.logMessageBuilder.build(logType: .performance, message: "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds", error: nil)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ message:String) {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:String) {
        let msg = self.logMessageBuilder.build(logType: logType, message: message, error: nil)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ message:Int) {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Int) {
        for logger in loggers {
            logger.log(logType, message)
        }
    }
    
    func log(_ message:Double) {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Double) {
        for logger in loggers {
            logger.log(logType, message)
        }
    }
    
    func log(_ message:Float) {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    func log(_ logType:LogType, _ message:Float) {
        for logger in loggers {
            logger.log(logType, message)
        }
    }
    
    func log(_ message:Any) {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: nil)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Any) {
        for logger in loggers {
            logger.log(logType, message)
        }
    }
    
    func log(_ message:Error) {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: message)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:Error) {
        for logger in loggers {
            logger.log(logType, message)
        }
    }
    
    func log(_ message:String, _ error:Error) {
        let msg = self.logMessageBuilder.build(logType: .info, message: message, error: error)
        for logger in loggers {
            logger.write(message: msg)
        }
    }
    
    func log(_ logType:LogType, _ message:String, _ error:Error) {
        for logger in loggers {
            logger.log(logType, message, error)
        }
    }
}

class LoggerFactory {
    
    fileprivate static var loggers:[Logger] = []
    
    static func append(logger:Logger) {
        Self.loggers.append(logger)
    }
    
    static func get(category:String, subCategory:String) -> LogDispatcher {
        return LogDispatcher(category: category, subCategory: subCategory, loggers: loggers)
    }
    
}

class FileLogger : Logger {
    
    fileprivate var logFileUrl:URL
    
    init(pathOfFolder: String) {
        self.logFileUrl = URL(fileURLWithPath: pathOfFolder)
        print("Writing log to file: \(logFileUrl.path)")
        self.write("Writing log to file: \(logFileUrl.path)")
    }
    
    convenience init() {
        self.init(pathOfFolder: Self.defaultLoggingDirectory().appending(path: Self.defaultLoggingFilename()).path())
    }
    
    fileprivate static func defaultLoggingFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
        let datePart = dateFormatter.string(from: Date())
        return "\(datePart).log"
    }
    
    fileprivate static func defaultLoggingDirectory() -> URL {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        let url = appSupportURL.appendingPathComponent("log")
        
        if !url.path.isDirectoryExists() {
            let (created, error) = url.path.mkdirs()
            if !created {
                print("ERROR: Unable to create logging directory - \(String(describing: error))")
            }
        }
        
        return url
    }
    
    func write(_ message:String) {
        DispatchQueue.global().async {
            
            do {
                try message.appendLineToURL(fileURL: self.logFileUrl)
            }catch {
                let msg = "\(LogType.iconOfType(LogType.error)) Unable to write log to file \(self.logFileUrl.path) - \(error)"
                print(msg)
            }
        }
    }
    
    func timecost(_ message:String, fromDate:Date) {
        self.write(message)
    }
    
    func log(_ message:String) {
        self.write(message)
    }
    
    func log(_ logType:LogType, _ message:String) {
        self.write(message)
    }
    
    func log(_ message:Int) {
        self.write(message)
    }
    
    func log(_ logType:LogType, _ message:Int) {
        self.write(message)
    }
    
    func log(_ message:Double) {
        self.write(message)
    }
    
    func log(_ logType:LogType, _ message:Double) {
        self.write(message)
    }
    
    func log(_ message:Float) {
        self.write(message)
    }
    
    func log(_ logType:LogType, _ message:Float) {
        self.write(message)
    }
    
    func log(_ message:Any) {
        self.write(message)
    }
    
    func log(_ logType:LogType, _ message:Any) {
        self.write(message)
    }
    
    func log(_ message:Error) {
        self.write(message)
    }
    
    func log(_ logType:LogType, _ message:Error) {
        self.write(message)
    }
    
    func log(_ message:String, _ error:Error) {
        self.write(message)
    }
    
    func log(_ logType:LogType, _ message:String, _ error:Error) {
        self.write(message)
    }
}

class ConsoleLogger : Logger {
    
    private let dtFormatter = ISO8601DateFormatter()
    
    private var category:String = ""
    private var subCategory:String = ""
    private var displayTypes:[LogType] = [.info, .error, .todo, .warning] // .debug not included by default
    
    private let fileLogger = FileLogger()
    
    init(category:String) {
        self.category = category
        self.dtFormatter.timeZone = TimeZone.current
    }
    
    convenience init(category:String, subCategory:String){
        self.init(category: category)
        self.subCategory = subCategory
    }
    
    convenience init(category:String, displayTypes:[LogType]){
        self.init(category: category)
        self.displayTypes = displayTypes
    }
    
    convenience init(category:String, subCategory:String, displayTypes:[LogType]){
        self.init(category: category)
        self.subCategory = subCategory
        self.displayTypes = displayTypes
    }
    
    convenience init(category:String, excludeTypes:[LogType]){
        self.init(category: category)
        let defaultTypes:Set<LogType> = Set(self.displayTypes)
        let removeTypes:Set<LogType> = Set(excludeTypes)
        self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
    }
    
    convenience init(category:String, subCategory:String, excludeTypes:[LogType]){
        self.init(category: category)
        self.subCategory = subCategory
        let defaultTypes:Set<LogType> = Set(self.displayTypes)
        let removeTypes:Set<LogType> = Set(excludeTypes)
        self.displayTypes = Array(defaultTypes.subtracting(removeTypes))
    }
    
    convenience init(category:String, includeTypes:[LogType]){
        self.init(category: category)
        for t in includeTypes {
            if let _ = self.displayTypes.firstIndex(of: t) {
               // continue
            }else{
                self.displayTypes.append(t)
            }
        }
    }
    
    convenience init(category:String, subCategory:String, includeTypes:[LogType]){
        self.init(category: category)
        self.subCategory = subCategory
        for t in includeTypes {
            if let _ = self.displayTypes.firstIndex(of: t) {
               // continue
            }else{
                self.displayTypes.append(t)
            }
        }
    }
    
    private func prefix() -> String {
        if subCategory == "" {
            return "\(self.dtFormatter.string(from: Date())) [\(category)]"
        }else{
            return "\(self.dtFormatter.string(from: Date())) [\(category)][\(subCategory)]"
        }
    }
    
    public func timecost(_ message:String, fromDate:Date){
        log(.performance, "\(message) - time cost: \(Date().timeIntervalSince(fromDate)) seconds")
    }
    
    public func log(_ message:String){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            let msg = "\(LogType.iconOfType(LogType.info)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ logType:LogType, _ message:String){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            let msg = "\(LogType.iconOfType(logType)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ message:Int){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            let msg = "\(LogType.iconOfType(LogType.info)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ logType:LogType, _ message:Int){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            let msg = "\(LogType.iconOfType(logType)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ message:Double){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            let msg = "\(LogType.iconOfType(LogType.info)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ logType:LogType, _ message:Double){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            let msg = "\(LogType.iconOfType(logType)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ message:Float){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            let msg = "\(LogType.iconOfType(LogType.info)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ logType:LogType, _ message:Float){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            let msg = "\(LogType.iconOfType(logType)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ message:Any){
        if let _ = self.displayTypes.firstIndex(of: .info) {
            let msg = "\(LogType.iconOfType(LogType.info)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ logType:LogType, _ message:Any){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            let msg = "\(LogType.iconOfType(logType)) \(prefix()) \(message)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ error:Error){
        if let _ = self.displayTypes.firstIndex(of: .error) {
            let msg = "\(LogType.iconOfType(LogType.error)) \(prefix()) \(error)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ logType:LogType, _ error:Error){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            let msg = "\(LogType.iconOfType(logType)) \(prefix()) \(error)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ message:String, _ error:Error){
        if let _ = self.displayTypes.firstIndex(of: .error) {
            let msg = "\(LogType.iconOfType(LogType.error)) \(prefix()) \(message) - \(error)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
    
    public func log(_ logType:LogType, _ message:String, _ error:Error){
        if let _ = self.displayTypes.firstIndex(of: logType) {
            let msg = "\(LogType.iconOfType(logType)) \(prefix()) \(message) - \(error)"
            print(msg)
            self.fileLogger.write(msg)
        }
    }
}

extension String {
    
    func isDirectoryExists() -> Bool {
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDir) {
            if isDir.boolValue == true {
                return true
            }
        }
        return false
    }
    
    func isFileExists() -> Bool {
        if FileManager.default.fileExists(atPath: self) {
            return true
        }
        return false
    }
    
    func mkdirs(logger:Logger? = nil) -> (Bool, Error?) {
        do {
            try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
        }catch{
            if let logger = logger {
                logger.log(error)
            }
            return (false, error)
        }
        return (true, nil)
    }
    
    func appendLineToURL(fileURL: URL) throws {
         try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
    
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
