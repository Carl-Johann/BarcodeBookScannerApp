//
//  GoogleBooksConstants.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 25/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation

extension GoogleBooksClient {
    
    struct GoogleBooksConstants {
        static let ApiKey = "AIzaSyA8sOQ5kQ_ksODktYp_O9ogrUKJc3yau-k"
        static let APIScheme = "https"
        static let APIHost = "www.googleapis.com"
        static let APIPath = "/books/v1/volumes"
    }
    
    struct GoogleBooksSearchParameterKeys {
        static let intitle = "intitle"
        static let inauthor = "inauthor"
        static let inpublisher = "inpublisher"
        static let subject = "subject"
        static let isbn = "isbn"
        static let lccn = "lccn"
        static let oclc = "oclc"
        static let q = "q"
    }
    
    struct GoogleBooksSearchParameterValues {
        static let key = "key"
    }
    
    struct GoogleBookShelfID {
        static let Favorites = 0
        static let Purchased = 1
        static let ToRead = 2
        static let ReadingNow = 3
        static let HaveRead = 4
        static let Reviewed = 5
        static let RecentlyViewed = 6
        static let MyEbooks = 7
        static let BooksForYou = 8
    }
    
    
    
}
