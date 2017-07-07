//
//  ConvenienceBook.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 06/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit


struct ConvenienceBook {
    
    var title = ""
    var isbn13 = ""
    var isbn10 = ""
    var smallThumbnail = ""
    var thumbnail = ""
    var description = ""
    var publisher = ""
    var publishedDate = ""
    var authors = ""
    var numberOfPages = ""
    var mainCategory = ""
    var categories = ""
    var rating = ""
    
    func getAllValues() -> [String : String] {
        let values: [String : String] = [
            "title": self.title,
            "isbn13": self.isbn13,
            "isbn10": self.isbn10,
            "smallThumbnail": self.smallThumbnail,
            "thumbnail": self.thumbnail,
            "description": self.description,
            "publisher": self.publisher,
            "publishedDate": self.publishedDate,
            "authors": self.authors,
            "numberOfPages": self.numberOfPages,
            "mainCategory": self.mainCategory,
            "categories": self.categories,
            "rating": self.rating
        ]
        
        return values
    }
    
    
    func getValuesToMakeUITextViewsOf() -> [String : String]{
        
        var ValuesToMakeUITextViewsOf: [String : String] = [
            "Title": self.title,
            "Description": self.description,
            "Publisher": self.publisher,
            "Published Date": self.publishedDate,
            "Page Count": self.numberOfPages,
            "Main Category": self.mainCategory,
            "Rating": self.rating
        ]
        
        // Removes all the empty key-value pairs in the array
        for value in ValuesToMakeUITextViewsOf {
            if value.value.isEmpty { ValuesToMakeUITextViewsOf.removeValue(forKey: value.key) }
        }
        
//        "Title": self.title,
//        "Description": self.description,
//        "Publisher": self.publisher,
//        "Published Date": self.publishedDate,
//        "Page Count": self.numberOfPages
//        createUITextViewValuesArray(key: <#T##String#>, valueToCheck: <#T##String#>, arrayToUpdate: <#T##[String : String]#>)

        // Makes sure that the 'author' is in the right plural form
//        if authors.count > 1 {
//            values.updateValue(self.authors, forKey: "Authors")
//        } else if authors.count == 1 {
//            values.updateValue(self.authors, forKey: "Author")
//        }
        
        
//        // Counts the number of comma. 1 comma = 1 author.
//        var numberOfCommas = 0
//        for character in authors.characters { if character == "," { numberOfCommas += 1 } }
//        
//        // Removes the " ," at the start of the string if any authors were found.
//        authors.characters.dropFirst(2)
//        
//        // Updates the 'ValuesToMakeUITextViewsOf' with the right plural form 
//        if numberOfCommas > 1 { ValuesToMakeUITextViewsOf.updateValue(self.authors, forKey: "Authors") }
//        else if numberOfCommas == 1 { ValuesToMakeUITextViewsOf.updateValue(self.authors, forKey: "Author") }
//
        
        let authorString = cleanAndCreateString(pluralKey: "Authors", singularKeyForm: "Author", stringToIterate: self.authors)
        
        return ValuesToMakeUITextViewsOf
    }

    
    
    
    
    
    

    func cleanAndCreateString(pluralKey: String, singularKeyForm: String, stringToIterate: String) -> [String : String] {
        var keyString: String = ""
        var valueString: String = ""
        
        var numberOfCommas = 0
        for character in stringToIterate.characters { if character == "," { numberOfCommas += 1 } }
        
        
        // Removes the " ," at the start of the string if any authors were found.
        valueString = String(stringToIterate.characters.dropFirst(2))

        if numberOfCommas > 1 {
//            values.updateValue(self.authors, forKey: "Authors")
            keyString = pluralKey
        } else if numberOfCommas == 1 {
//            values.updateValue(self.authors, forKey: "Author")
            keyString = singularKeyForm
        }
        
        
        return [keyString : valueString]
    }
    
    
    
}
