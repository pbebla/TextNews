//
//  ViewController.swift
//  EnterContact
//
//  Created by Pauldin Bebla on 5/3/19.
//  Copyright © 2019 Pauldin Bebla. All rights reserved.
//
import Contacts
import UIKit
import MessageUI
import CoreData
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
let appDelegate = UIApplication.shared.delegate as! AppDelegate
var contactList = [Contact]()
class MainMenu: UIViewController, MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            contactList = try context.fetch(Contact.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }*/
    @IBAction func sendMessage(_ sender: Any) {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = ""
            let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
            do {
                let contacts = try context.fetch(fetchRequest)
                contactList = contacts
                
            } catch {}
            var test = [String]()
            for number in contactList {
                test.append(number.phone!)
            }
            messageVC.recipients = test
            messageVC.messageComposeDelegate = self
            self.present(messageVC, animated: true, completion: nil)
    }
}
//Add a Contact
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var fname: UITextField!
    @IBOutlet weak var lname: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBAction func submit(_ sender: UIButton) {
        let store = CNContactStore()
        let predicate: NSPredicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phone.text!))
        let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactEmailAddressesKey,CNContactPhoneNumbersKey]
        //let storedContacts = [Contact]()
        var data: [Contact] = []
        //Search AppData to see if its already on app
        var isFound=false
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            let result = try context.fetch(fetchRequest)
            for dat in result{
                if dat.phone==phone.text!{
                    isFound=true
                }
            }
            data=result
        } catch {}
        //Invalid if insufficient entries
        if phone.text=="" || (fname.text=="" && lname.text==""){
            let alert = UIAlertController(title: "Invalid Contact", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"Invalid\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        //Do nothing if already in app
        else if (isFound){
            let alert = UIAlertController(title: "Contact already stored.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"Duplicate\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        //Add to app
        else{
            var addendum = ""
            //If already in phone, take info from there
            let temp = try? store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
            if temp!.count>0{
                // Array containing all unified contacts from everywhere
                let temp2 = temp?.first!.mutableCopy() as! CNMutableContact
                fname.text=temp2.givenName
                lname.text=temp2.familyName
                phone.text=(temp2.phoneNumbers[0].value).stringValue
                if(temp2.emailAddresses.count>0){
                    email.text=(temp2.emailAddresses[0].value) as String
                }
                addendum="Contact already stored in device."
            }
            //Brand new contact
            else{
                let contact = CNMutableContact()
                contact.phoneNumbers = [CNLabeledValue(
                    label:CNLabelPhoneNumberiPhone,
                    value:CNPhoneNumber(stringValue:phone.text!))]
                contact.emailAddresses=[CNLabeledValue(label:CNLabelEmailiCloud, value:NSString(string: email.text!))]
                contact.givenName = fname.text!
                contact.familyName = lname.text!
                let saveRequest = CNSaveRequest()
                saveRequest.add(contact, toContainerWithIdentifier:nil)
                try! store.execute(saveRequest)
            }
            let person = Contact(context: context)
            person.phone=phone.text!
            person.first=fname.text!
            person.last=lname.text!
            person.email=email.text!
            contactList.append(person)
            appDelegate.saveContext()
            fname.text=""
            lname.text=""
            phone.text=""
            email.text=""
            let alert = UIAlertController(title: "Contact Added.", message:addendum, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        
        }
    }

}

