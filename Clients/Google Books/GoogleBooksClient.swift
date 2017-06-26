//
//  GoogleBooksClient.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 25/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation

struct GoogleBooksClient {
    
    let session = URLSession.shared
    
    
    
    
    
    func getBookInformationFromBarcode( _ barcode: Int, CHForBookInformation: @escaping (_ succes: Bool, _ data: AnyObject?) -> Void) {
        
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
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                print("Couldn't fetch sessionID")
                CHForBookInformation(false, nil); return
            }
            
            let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
            
            print(parsedResult)
            
            CHForBookInformation(true, parsedResult)
        }
        
        
        task.resume()
        
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
        print(componentsString)
        if componentsString.characters.last == "+" { componentsString.characters.removeLast() }
        print(componentsString)
        
        return componentsString
    }
    
    static let sharedInstance = GoogleBooksClient()
    
}
