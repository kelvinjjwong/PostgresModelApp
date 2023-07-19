//
//  FileLogger.swift
//  PostgresModelApp
//
//  Created by Kelvin Wong on 2023/7/19.
//

import Foundation

class FileLogger : LogWriter {
    
    fileprivate var logFileUrl:URL
    
    init(pathOfFolder: String) {
        self.logFileUrl = URL(fileURLWithPath: pathOfFolder)
        print("Writing log to file: \(logFileUrl.path)")
        self.write(message: "Writing log to file: \(logFileUrl.path)")
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
    
    func write(message:String) {
        DispatchQueue.global().async {
            
            do {
                try message.appendLineToURL(fileURL: self.logFileUrl)
            }catch {
                let msg = "\(LogType.iconOfType(LogType.error)) Unable to write log to file \(self.logFileUrl.path) - \(error)"
                print(msg)
            }
        }
    }
}
