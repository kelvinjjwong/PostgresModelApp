//
//  ViewController.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Cocoa
import LoggerFactory

class ViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "ViewController")
    
    @IBOutlet weak var txtHostname: NSTextField!
    @IBOutlet weak var txtUsername: NSTextField!
    @IBOutlet weak var txtDatabase: NSTextField!
    @IBOutlet var txtResponse: NSTextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.txtHostname.stringValue = "127.0.0.1"
        self.txtUsername.stringValue = "postgres"
        self.txtDatabase.stringValue = "ModelTest"
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func btnQuery(_ sender: NSButton) {
        let _ = PostgresDB.connect(database: self.txtDatabase.stringValue, host: self.txtHostname.stringValue, user: self.txtUsername.stringValue)
        
        let records = FooDao.default.getFoos()
        
        for record in records {
            self.logger.log("[record]: \(record.id) \(record.name) \(record.age)")
        }
    }
    
}

