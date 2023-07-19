//
//  Extensions.swift
//  PostgresModelApp
//
//  Created by Kelvin Wong on 2023/7/19.
//

import Foundation

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
