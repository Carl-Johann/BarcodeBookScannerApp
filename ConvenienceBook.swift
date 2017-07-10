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
    
    var isThumbnailAvailable: Bool = false
    
    var title = ""
    var isbn13 = ""
    var isbn10 = ""
    
    var smallThumbnail = ""
    var thumbnail = ""
    var thumbnailIsSmall = ""
    var mediumThumbnail = ""
    var largeThumbnail = ""
    var extraLargeThumbnail = ""
    
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
    
    func getBiggestThumbnail() -> String {
        
        // Ordered by size. Last is the largest
        var thumbnails: [String : String] = [
            "smallThumbnail": self.smallThumbnail,
            "thumbnail": self.thumbnail,
            "thumbnailIsSmall": self.thumbnailIsSmall,
            "mediumThumbnail": self.mediumThumbnail,
            "largeThumbnail": self.largeThumbnail,
            "extraLargeThumbnail": self.extraLargeThumbnail
        ]
        
        for thumbnailValue in thumbnails { if thumbnailValue.value.isEmpty { thumbnails.removeValue(forKey: thumbnailValue.key) } }
        // Returns the last value, which is the largest image.
        var largestThumbnail = ""
        if !(thumbnails.isEmpty) { largestThumbnail = thumbnails.values.reversed().first! }
        return largestThumbnail
    }
    
    func getValuesToMakeUIViewsOf() -> [String : String]{
        
        var ValuesToMakeUIViewsOf: [String : String] = [
            "Title": self.title,
            "Description": self.description,
            "Publisher": self.publisher,
            "Publish Date": self.publishedDate,
            "Page Count": self.numberOfPages,
            "Main Category": self.mainCategory,
            "Rating": self.rating
        ]
        
        let (authorKeyString, authorValueString) = cleanAndCreateString(pluralKey: "Authors", singularKeyForm: "Author", stringToIterate: self.authors)
        let (categoryKeyString, categoryValueString) = cleanAndCreateString(pluralKey: "Categories", singularKeyForm: "Category", stringToIterate: self.categories)
        
        ValuesToMakeUIViewsOf.updateValue(authorValueString, forKey: authorKeyString)
        ValuesToMakeUIViewsOf.updateValue(categoryValueString, forKey: categoryKeyString)
        
        // Removes all the empty key-value pairs in the array
        for value in ValuesToMakeUIViewsOf {
            if value.value.isEmpty { ValuesToMakeUIViewsOf.removeValue(forKey: value.key) }
        }
        
        return ValuesToMakeUIViewsOf        
    }

    
    func cleanAndCreateString(pluralKey: String, singularKeyForm: String, stringToIterate: String) -> (String, String) {
        var keyString: String = ""
        var valueString: String = ""
        
        var numberOfCommas = 0
        for character in stringToIterate.characters { if character == "," { numberOfCommas += 1 } }
        
        
        // Removes the " ," at the start of the string if any authors were found.
        valueString = String(stringToIterate.characters.dropFirst(2))

        if numberOfCommas > 1 {
            keyString = pluralKey
        } else if numberOfCommas == 1 {
            keyString = singularKeyForm
        }
        
    
        return (keyString, valueString)
    }
    
    
}
