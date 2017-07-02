//
//  BarcodeScannerViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 25/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        let label = UILabel(frame: CGRect(x: 160, y: 200, width: 200, height: 21))
//        
//        label.layer.borderColor = UIColor.black.cgColor
//        label.layer.borderWidth = 1
//        label.layer.cornerRadius = 4
//        
//        view.addSubview(label)
//        view.bringSubview(toFront: label)
//        
        
        // Sets up the camera, and barcode scanner
        setupCamera()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    
    
    func getInformationFromScannedBook(items: [[String : AnyObject]]) -> [AnyHashable : Any] {
        
//        var values = [AnyHashable : Any]()
//        
//        var isbn13 = ""
//        var isbn10 = ""
//        var title = ""
//        var smallThumbnail = ""
//        var thumbnail = ""
        var values = [
            "title": "",
            "isbn13": "",
            "isbn10": "",
            "smallThumbnail": "",
            "thumbnail": ""
        ] as [AnyHashable : Any]

        
        // Safely unwraps the desired values from the JSON gotten from scanning the barcode, and calling the 'getBookInformationFromBarcode' function
        for item in items {
            guard let volumeInfo = item["volumeInfo"] as? [String : AnyObject] else { print(3); return values }
            guard let bookTitle = volumeInfo["title"] as? String else { print("'title' wasn't accessible in 'volumeInfo'"); return values }
            guard let imageLinks = volumeInfo["imageLinks"] as? [String : AnyObject] else { print(4); return values }
            guard let smallBookThumbnail = imageLinks["smallThumbnail"] as? String else { print("'smallThumbnail' wasn't accessible in "); return values }
            guard let bookThumbnail = imageLinks["thumbnail"] as? String else { print("'thumbnail' wasn't accessible in "); return values }
            guard let industryIdentifiers = volumeInfo["industryIdentifiers"] as? [[String : AnyObject]] else {
                print("'industryIdentifiers' wasn't accessible in 'volumeInfo'"); return values }
            
            // Iterates through 'industryIdentifiers', checks and sets the ISBN values
            for identifier in industryIdentifiers {
                guard let isbnNumber = identifier["identifier"] as? String else { print("ISBNNumber wasn't accessible in 'identifier' in 'industryIdentifiers'"); return values }
                guard let isbnNumberIdentifier = identifier["type"] as? String else { print("'type' wasn't accessible in 'identifier' in 'industryIdentifiers'"); return values }
                
                // Checks and sets the corensponding isbn number values
                if isbnNumberIdentifier == "isbn10" { values["isbn10"] = isbnNumber }
                else if isbnNumberIdentifier == "isbn13" { values["isbn13"] = isbnNumber }
                
            }
            
            // Asign the recently retrived values to placeholders, so that they can be used in the 'updateChildValues' function
            values["title"] = bookTitle
            values["smallThumbnail"] = smallBookThumbnail
            values["thumbnail"] = bookThumbnail
        
        }
        
//        values = [
//            "title": title,
//            "ISBN_13": isbn13,
//            "ISBN_10": isbn10,
//            "smallThumbnail": smallThumbnail,
//            "thumbnail": thumbnail
//        ]
        
        return values
    }
    
    
    
    
    
    func updateChildValues(values: [AnyHashable : Any]) {
        guard let firebaseUserUID = Auth.auth().currentUser?.uid else { print("Current Firebase user UID == nil"); return }
        let ref = Database.database().reference(fromURL: "https://barcodebookscanner.firebaseio.com/Users/\(firebaseUserUID)/")
        let usersBooksRef = ref.child("books")
        
        let isbn13 = values["isbn13"] as! String
        let isbn10 = values["isbn10"] as! String
        
        var scannedBookRef = usersBooksRef.child(isbn13)
        
        // To avoid an empty books-child 'title' in our Firebase database,
        // we check if any of the isbn values are empty. If both of them are empty we raise an error
        if isbn13.isEmpty {
            scannedBookRef = usersBooksRef.child(isbn10)
        } else if isbn10.isEmpty {
            // If both isbn values are empty we do not want to update our Firebase database, and we want to inform the user.
            presentISBNScanningError()
            return
        }

        
        
        scannedBookRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                
                
                return
            }
        }
        
        
        print("Scan and network calls were succesfull")
    }
    
    
    
        
    func updateChildValuesErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "An error occured. Try agian", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

