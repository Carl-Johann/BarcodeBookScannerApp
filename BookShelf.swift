//
//  BookShelf.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 27/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

//import PureLayout
import UIKit
import Foundation
import GoogleSignIn
//import GoogleToolboxForMac
import Firebase
import GTMOAuth2
//import FirebaseInstanceID

class BookShelf: UICollectionViewController {
    
    var currentUser: GIDGoogleUser?
    
    override func viewDidLoad() {
        let button = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        //button.frame = CGRect(origin: 100, size: 100)
        //        button.center = CGPoint(x: 100, y: 100)
        button.backgroundColor = UIColor.cyan
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        
        //        view.bringSubview(toFront: button)
    }
    
    
    
    func buttonAction() {
        
//    InstanceID.token()
        
        if (GIDSignIn.sharedInstance().currentUser != nil) {
            guard let accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken else { print("AccesToken == nil"); return }
          
            
            guard let url = URL(string: "https://www.googleapis.com/books/v1/mylibrary/bookshelves/7/volumes?access_token=\(accessToken)") else
            { print("Url is invalid"); return }
            let request = URLRequest(url: url)
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil {
                    print("Error occured", error!)
                    return
                }
                
                let parsedResult = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject
                print(parsedResult)
                
                guard let session = parsedResult["items"] as? [[String:AnyObject]] else {
                    print("Couldn't find items in parsedResult ")
                    
                    return
                }
                
                
//                for book in parsedResult {
//                
//                
//                }
                
                
            }
            task.resume()
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCellID", for: indexPath) as! BookCell
        //cell.backgroundColor = UIColor.black
        // Configure the cell
        return cell
    }
    
}
