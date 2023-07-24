//
//  ViewController.swift
//  PostgresModelApp
//
//  Created by kelvinwong on 2023/7/19.
//

import Cocoa
import LoggerFactory
import PostgresModelFactory

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
        let db = PostgresDB.connect(database: self.txtDatabase.stringValue, host: self.txtHostname.stringValue, user: self.txtUsername.stringValue)
        
        // VERSION MIGRATE
        FooDao.default.versionCheck(cleanAll: true) // true for DEBUG, false for RELEASE
        
        // QUERY
        let records = FooDao.default.getFoos()
        
        for record in records {
            self.logger.log("[record]: \(record.id) \(record.name) \(record.age)")
        }
        let dtFormatter = ISO8601DateFormatter()
        
        // INSERT
        let newName = "NewPerson_\(dtFormatter.string(from: Date()))"
        let randomAge = Int.random(in: 2..<100)
        FooDao.default.insertFoo(name: newName, age: randomAge)
        
        // QUERY ONE and UPDATE
        let foos = FooDao.default.queryFoo(name: "Tom")
        if !foos.isEmpty {
            let foo = foos[0]
            if let id = foo.id {
                FooDao.default.updateFoo(id: id, name: "Tommy", age: nil)
            }
        }
        
        print("==============")
        
        // QUERY ALL
        let rs = FooDao.default.getFoos()
        
        for r in rs {
            self.logger.log("[record]: \(r.id) \(r.name) \(r.age)")
        }
    }
    
}

