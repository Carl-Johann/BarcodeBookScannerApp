//
//  Book+CoreDataProperties.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 07/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var bookCoverAsData: NSData?
    @NSManaged public var bookTitle: String?
    @NSManaged public var firebaseUID: String?
    @NSManaged public var isbn13: Int64

}
