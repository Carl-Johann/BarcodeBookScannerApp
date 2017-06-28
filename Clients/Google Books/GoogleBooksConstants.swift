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
        static let ApiKey = "AIzaSyD7_eufgD6tYKJxPx9yBi00e-GmH2gdQj4"
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
    
    
    
    
    
}
