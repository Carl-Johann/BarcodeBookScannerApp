//
//  Book+CoreDataProperties.swift
//  BarcodeBookScanner
//
//  Created by Joe on 17/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var authors: String?
    @NSManaged public var bookCoverAsData: NSData?
    @NSManaged public var bookDescription: String?
    @NSManaged public var bookID: String?
    @NSManaged public var bookTitle: String?
    @NSManaged public var categories: String?
    @NSManaged public var extraLargeThumbnail: String?
    @NSManaged public var firebaseUID: String?
    @NSManaged public var isbn10: String?
    @NSManaged public var isbn13: Int64
    @NSManaged public var largeThumbnail: String?
    @NSManaged public var mainCategory: String?
    @NSManaged public var mediumThumbnail: String?
    @NSManaged public var numberOfPages: String?
    @NSManaged public var publishedDate: String?
    @NSManaged public var publisher: String?
    @NSManaged public var rating: String?
    @NSManaged public var smallThumbnail: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var thumbnailIsSmall: String?

}
