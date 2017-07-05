//
//  GoogleBooksClient.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 25/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import GoogleSignIn

struct GoogleBooksClient {
    
    let session = URLSession.shared

    func getBookInformationFromBarcode( _ barcode: Int, CHForBookInformation: @escaping (_ succes: Bool, _ data: [String : AnyObject], _ errorMessage: String) -> Void) {
        DispatchQueue.main.async {
            
            
            let lort = [
                GoogleBooksClient.GoogleBooksSearchParameterKeys.isbn : barcode
            ]
            
            let searchParameter = GoogleBooksClient.sharedInstance.makeSearchQueryItemValue(lort as [String : AnyObject])
            let parameters = [
                GoogleBooksClient.GoogleBooksSearchParameterKeys.q : searchParameter,
                GoogleBooksClient.GoogleBooksSearchParameterValues.key : GoogleBooksClient.GoogleBooksConstants.ApiKey
            ]
            
            let url = GoogleBooksClient.sharedInstance.flickrURLFromParameters(parameters as [String : AnyObject])
            let request = NSMutableURLRequest(url: url)
            
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
                    print("No items were downloaded. Book not supported")
                    CHForBookInformation(false, [:], "Book is not supported, try another book")
                    return
                }
                
                CHForBookInformation(true, parsedResult as! [String : AnyObject], "")
                                     
            }
            
            
            task.resume()
        }
    }
    
    
    func getSpecificBookShelfFromUser(BookshelfID: Int, completionHandler: @escaping (_ succes: Bool, _ items: [[String:AnyObject]]) -> Void) {
        DispatchQueue.main.async {
            
            if (GIDSignIn.sharedInstance().currentUser != nil) {
                guard let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken else { print("AccesToken == nil"); return }
                
                
                guard let url = URL(string: "https://www.googleapis.com/books/v1/mylibrary/bookshelves/\(BookshelfID)/volumes?access_token=\(accessToken)") else{
                    print("Url is invalid for 'getSpecificBookShelfFromUser'")
                    completionHandler(false, [[:]])
                    return
                }
                
                let request = URLRequest(url: url)
                
                
                let task = self.session.dataTask(with: request as URLRequest) { data, response, error in
                    if error != nil {
                        print("Error occured making a URL request to googleAPI", error!)
                        completionHandler(false, [[:]])
                        return
                    }
                    
                    
                    
                    let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
                    
                    
                    guard let items = parsedResult["items"] as? [[String:AnyObject]] else {
                        print("Couldn't find items in parsedResult")
                        completionHandler(false, [[:]])
                        return
                    }
                    
                    completionHandler(true, items)
                    
                }
                task.resume()
            }
        }
    }
    
    
    
    func flickrURLFromParameters(_ parameters: [String: AnyObject] = [:], _ isSearchCall: String? = nil) -> URL {
        
        var components = URLComponents()
        
        components.scheme = GoogleBooksConstants.APIScheme
        components.host = GoogleBooksConstants.APIHost
        components.path = GoogleBooksConstants.APIPath
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
            
        }
        print("GoogleBooks URL: \(components.url!)")
        return components.url!
    }
    
    func makeSearchQueryItemValue(_ parameters: [String:AnyObject]) -> String {
        var componentsString: String = ""
        
        for (key, value) in parameters {
            let queryItem = "\(key):\(value)+"
            componentsString.append(queryItem)
        }
        if componentsString.characters.last == "+" { componentsString.characters.removeLast() }
        
        return componentsString
    }
    
    
    
    
    
    static let sharedInstance = GoogleBooksClient()
}
