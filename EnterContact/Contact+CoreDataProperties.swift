//
//  Contact+CoreDataProperties.swift
//  
//
//  Created by Pauldin Bebla on 7/22/19.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var phone: String?
    @NSManaged public var first: String?
    @NSManaged public var last: String?
    @NSManaged public var email: String?
}
