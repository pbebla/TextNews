//
//  GroupMessage.swift
//  EnterContact
//
//  Created by Pauldin Bebla on 5/5/19.
//  Copyright © 2019 Pauldin Bebla. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import CoreData
import Contacts
import ContactsUI
class GroupMessage: UIViewController, UITableViewDataSource{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! //1.
        
        let text = data[indexPath.row] //2.
        
        cell.textLabel?.text = text.first! + " " + text.last! //3.
        cell.detailTextLabel?.text = text.phone! + " " + text.email!
        
        return cell //4.
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let commit = data[indexPath.row]
            let alert = UIAlertController(title: "Delete Contact from Phone too?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes action"), style: .default, handler: { _ in
                self.deleteRecord(contact: commit)
                self.context.delete(commit)
                self.data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                self.appDelegate.saveContext()
                NSLog("The \"DeletefromPhone\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No action"), style: .default, handler: { _ in
                NSLog("The \"DontDeletefromPhone\" alert occured.")
                self.context.delete(commit)
                self.data.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                self.appDelegate.saveContext()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { _ in
                NSLog("The \"Cancel\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            for dat in result{
                print(dat.value(forKey: "phone") as! String)
            }
            self.data=result
        } catch {}
        
        tableView.dataSource = self
    }
    
    func deleteRecord(contact: Contact){
        let saveRequest = CNSaveRequest()
        let predicate: NSPredicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: contact.phone!))
        let store = CNContactStore()
        let keys = [CNContactPhoneNumbersKey]
        if let temp = try? store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor]){
            // Array containing all unified contacts from everywhere
            let temp2 = temp.first!.mutableCopy() as! CNMutableContact
            saveRequest.delete(temp2)
        }
        try! store.execute(saveRequest)
    }
    
    private var data: [Contact] = []
    
    @IBOutlet var tableView: UITableView!
}
