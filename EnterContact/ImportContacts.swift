//
//  ImportContacts.swift
//  EnterContact
//
//  Created by Pauldin Bebla on 7/23/19.
//  Copyright © 2019 Pauldin Bebla. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import CoreData
import Contacts

class ImportContacts: UIViewController, UITableViewDataSource {
    var list = [CNContact]()
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.allowsMultipleSelectionDuringEditing = true
        self.navigationItem.rightBarButtonItem = editButtonItem
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if err != nil {
                print("Failed to reuqest access.")
                return
            }
            if granted {
                print("Access granted.")
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopper) in
                        self.list.append(contact)
                    })
                } catch let err {
                    print("Failed to enumerate.", err)
                }
                
            } else {
                print("Access denied.")
            }
        }
        tableView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")! //1.
        
        let text = list[indexPath.row] //2.
        
        cell.textLabel?.text = text.givenName + " " + text.familyName//3.
        
        return cell //4.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
