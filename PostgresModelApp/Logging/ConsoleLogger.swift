//
//  ConsoleLogger.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/12/11.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation


class ConsoleLogger : LogWriter {
    
    func write(message: String) {
        print(message)
    }
    
}
