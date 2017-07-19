//
//  GoogleBooksClient.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 25/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import GoogleSignIn
import UIKit

struct GoogleBooksClient {
    
    let session = URLSession.shared

    func getBookInformationFromBarcode( _ barcode: Int, CHForBookInformation: @escaping (_ succes: Bool, _ data: [String : AnyObject], _ errorMessage: String) -> Void) {
        DispatchQueue.main.async {
            print("getBookInformationFromBarcode called")
//            
//            let lort = [
//                GoogleBooksClient.GoogleBooksSearchParameterKeys.isbn : barcode
//            ]
//            
//            let searchParameter = GoogleBooksClient.sharedInstance.makeSearchQueryItemValue(lort as [String : AnyObject])
//            let parameters = [
//                GoogleBooksClient.GoogleBooksSearchParameterKeys.q : searchParameter,
//                GoogleBooksClient.GoogleBooksSearchParameterValues.key : GoogleBooksClient.GoogleBooksConstants.ApiKey
//            ]
//            
//            let url = GoogleBooksClient.sharedInstance.flickrURLFromParameters(parameters as [String : AnyObject])
//            let request = NSMutableURLRequest(url: url)
            
            let request = URLRequest(url: URL(string:"https://www.googleapis.com/books/v1/volumes?q=isbn:\(barcode)&key=AIzaSyA8sOQ5kQ_ksODktYp_O9ogrUKJc3yau-k")!)
            
            let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil {
                    print("An error occured trying to download book")
                    CHForBookInformation(false, [:], "Networking error. Try again later"); return
                }
                
                
                let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
                guard let items = parsedResult as? [String : AnyObject] else {
                    print("Items couldn't be safely converted to '[String : AnyObject]'")
                    CHForBookInformation(false, [:], "Internal error. Try agian later") ; return
                }
                guard let totalItems = items["totalItems"] as? Int else {
                    print("Error retrieving 'totalItems' in 'items'")
                    CHForBookInformation(false, [:], "Internal error. Try agian later"); return
                }
                
                // Checks if any books have been retrieved.
                if totalItems == 0 {
                    CHForBookInformation(false, [:], "Book is not supported, try another book"); return
                }
                
                CHForBookInformation(true, parsedResult as! [String : AnyObject], "")
                                     
            }
            
            
            task.resume()
        }
    }
    
    
    func getSpecificBookShelfFromUser(BookshelfID: Int, completionHandler: @escaping (_ succes: Bool, _ succesDescription: String, _ items: [[String:AnyObject]]?) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if (GIDSignIn.sharedInstance().currentUser != nil) {
                guard let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken else { print("AccesToken == nil"); return }
                
                guard let url = URL(string: "https://www.googleapis.com/books/v1/mylibrary/bookshelves/\(BookshelfID)/volumes?access_token=\(accessToken)") else {
                    print("Url is invalid for 'getSpecificBookShelfFromUser'")
                    completionHandler(false, "Internal error. Try agian later", nil); return
                }
                
                let request = URLRequest(url: url)
                
                
                let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
                    if error != nil {
                        print("Error occured making a URL request to googleAPI", error!)
                        completionHandler(false, "Internal error. Try agian", nil); return
                    }
                    
                    let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
                    
                    guard let numberOfBooks = parsedResult["totalItems"] as? Int else {
                        print("totalItems as 'Int' failed")
                        completionHandler(false, "Internal error. Try agian later", nil); return
                    }
                    
                    if numberOfBooks == 0 {
                        completionHandler(true, "No books in bookshelf", nil); return
                    }
                    
                    guard let items = parsedResult["items"] as? [[String:AnyObject]] else {
                        print("Couldn't find items in parsedResult")
                        completionHandler(false, "Internal error. Try agian", nil); return
                    }
                    
                    completionHandler(true, "", items)
                    
                }
                task.resume()
            }
        }
    }
    
    
    func postToBookshelf(BookshelfID: Int, bookID: String, add: Bool) {
        let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
        var postType: String
        
        if add == true { postType = "addVolume"
        } else { postType = "removeVolume" }
        
        DispatchQueue.global(qos: .background).async {
            
            // bookshelfID  -- good
            // bookID       -- good
            // add          -- good
            
            let url = URL(string: "https://www.googleapis.com/books/v1/mylibrary/bookshelves/\(BookshelfID)/\(postType)?volumeId=\(bookID)&key=AIzaSyA8sOQ5kQ_ksODktYp_O9ogrUKJc3yau-k")

            var request = URLRequest(url: url!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("CONTENT_LENGTH", forHTTPHeaderField: "Content-Length")
            request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            
            self.session.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil {
                    print("An error occured trying to post to bookshelf"); return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
                print("Post statusCode:", statusCode)
                
            }.resume()
            
            
        }
    }
    
    
    func getConvenienceBookFromScannedBook(items: [[String : AnyObject]]) -> ConvenienceBook {
        
        var scannedBook = ConvenienceBook()
        
        // Safely unwraps the desired values from the JSON gotten from scanning the barcode, and calling the 'getBookInformationFromBarcode' function
        for item in items {
            guard let volumeInfo = item["volumeInfo"] as? [String : AnyObject] else { print("volumeInfo wasn't accessible in item"); return scannedBook }
            guard let bookID = item["id"] as? String else { print("'id' wasn't accessible in 'item'"); return scannedBook }
            guard let bookTitle = volumeInfo["title"] as? String else { print("'title' wasn't accessible in 'volumeInfo'"); return scannedBook }
            
            scannedBook.bookID = bookID
            scannedBook.title = bookTitle
            
            if let imageLinks = volumeInfo["imageLinks"] as? [String : AnyObject] {
                
                if let smallBookThumbnail = imageLinks["smallThumbnail"] as? String { scannedBook.smallThumbnail = smallBookThumbnail }
                if let bookThumbnail = imageLinks["thumbnail"] as? String { scannedBook.thumbnail = bookThumbnail }
                if let thumbnalIsSmall = imageLinks["small"] as? String { scannedBook.thumbnailIsSmall = thumbnalIsSmall }
                if let mediumThumbnail = imageLinks["medium"] as? String { scannedBook.mediumThumbnail = mediumThumbnail }
                if let largeThumbnail = imageLinks["large"] as? String { scannedBook.largeThumbnail = largeThumbnail }
                if let extraLargeThumbnail = imageLinks["extraLarge"] as? String { scannedBook.extraLargeThumbnail = extraLargeThumbnail }
            }
            
            if let publisher = volumeInfo["publisher"] as? String { scannedBook.publisher = publisher }
            if let publishedDate = volumeInfo["publishedDate"] as? String { scannedBook.publishedDate = publishedDate}
            if let numberOfPages = volumeInfo["pageCount"] as? Int { scannedBook.numberOfPages = String(numberOfPages) }
            if let mainCategory = volumeInfo["mainCategory"] as? String { scannedBook.mainCategory = mainCategory }
            
            
            // Checks if the key("authors", "categories") is available in 'volumeInfo'.
            // If it is, we itterate through it, and append the value in a string to 'scannedBook' where it is further 'treated'
            if let authors = volumeInfo["authors"] as? [String] { for author in authors { scannedBook.authors.append(", \(author)")  } }
            if let categories = volumeInfo["categories"] as? [String] { for category in categories { scannedBook.categories.append(", \(category)") } }
            
            
            
            
            guard let industryIdentifiers = volumeInfo["industryIdentifiers"] as? [[String : AnyObject]] else {
                print("'industryIdentifiers' wasn't accessible in 'volumeInfo'"); return scannedBook }
            
            // Iterates through 'industryIdentifiers', checks and sets the ISBN values
            for identifier in industryIdentifiers {
                guard let isbnNumber = identifier["identifier"] as? String else { print("ISBNNumber wasn't accessible in 'identifier' in 'industryIdentifiers'"); return scannedBook }
                guard let isbnNumberIdentifier = identifier["type"] as? String else { print("'type' wasn't accessible in 'identifier' in 'industryIdentifiers'"); return scannedBook }
                
                // Checks the key 'isbnNumberIdentifier', and sets the corensponding isbn number values
                if isbnNumberIdentifier == "ISBN_10" { scannedBook.isbn10 = isbnNumber }
                else if isbnNumberIdentifier == "ISBN_13" { scannedBook.isbn13 = isbnNumber }
                
            }
        }
        
        return scannedBook
    }
    
    
    
    
    func getAuthenticatedUsersBookshelfs(completionHandler: @escaping (_ succes: Bool, _ items: [[String: AnyObject]]?) -> Void) {
        let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
        let url = URL(string: "https://www.googleapis.com/books/v1/mylibrary/bookshelves?access_token=\(accessToken!)")!
        
        let request = URLRequest(url: url)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Couldn't get user's bookshelfs"); print(error!)
                completionHandler(false, nil); return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!") ; return
            }

            let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            
            guard let items = parsedResult as? [String : AnyObject] else {
                print("Items couldn't be safely converted to '[String : AnyObject]'")
                completionHandler(false, nil) ; return
            }

            guard let bookshelfs = items["items"] as? [[String : AnyObject]] else { print("Can't get 'items' in 'parsedResult'")
                completionHandler(false, nil); return
            }
            
            completionHandler(true, bookshelfs)
            
        }.resume()
        
    }
    
    
//    
//    
//    func flickrURLFromParameters(_ parameters: [String: AnyObject] = [:], _ isSearchCall: String? = nil) -> URL {
//        
//        var components = URLComponents()
//        
//        components.scheme = GoogleBooksConstants.APIScheme
//        components.host = GoogleBooksConstants.APIHost
//        components.path = GoogleBooksConstants.APIPath
//        components.queryItems = [URLQueryItem]()
//        for (key, value) in parameters {
//            let queryItem = URLQueryItem(name: key, value: "\(value)")
//            components.queryItems!.append(queryItem)
//            
//        }
//        return components.url!
//    }
//    
//    func makeSearchQueryItemValue(_ parameters: [String:AnyObject]) -> String {
//        var componentsString: String = ""
//        
//        for (key, value) in parameters {
//            let queryItem = "\(key):\(value)+"
//            componentsString.append(queryItem)
//        }
//        if componentsString.characters.last == "+" { componentsString.characters.removeLast() }
//        
//        
//        return componentsString
//    }
//    
    
    
    static let sharedInstance = GoogleBooksClient()
}
