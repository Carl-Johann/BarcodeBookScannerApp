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
        print("BarcodeScannerViewController did load")
        // Sets up the camera, and barcode scanner
        setupCamera()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("BarcodeScannerViewController will appear")
        DispatchQueue.main.async {
            // If session is not running
            if !(self.session.isRunning) {
                self.session.startRunning()
                
             //   self.checkAndAddOutput()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        print("BarcodeScannerViewController did disappear")
        
//        DispatchQueue.main.async {
//            if self.session.isRunning { self.session.stopRunning() }
//        }
        
    }
    func getInformationFromScannedBook(items: [[String : AnyObject]]) -> [String : Any] {
        
        var values = [
            "title": "",
            "isbn13": "",
            "isbn10": "",
            "smallThumbnail": "",
            "thumbnail": ""
        ] as [String : Any]

        
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
                if isbnNumberIdentifier == "ISBN_10" { values["isbn10"] = isbnNumber }
                else if isbnNumberIdentifier == "ISBN_13" { values["isbn13"] = isbnNumber }
                
            }
            
            // Asign the recently retrived values to placeholders, so that they can be used in the 'updateChildValues' function
            values["title"] = bookTitle
            values["smallThumbnail"] = smallBookThumbnail
            values["thumbnail"] = bookThumbnail
        
        }
        
        return values
    }
    
    
    
    
    
    func updateChildValues(values: [String : Any]) {
        guard let firebaseUserUID = Auth.auth().currentUser?.uid else { print("Current Firebase user UID == nil"); return }
        let ref = Database.database().reference(fromURL: "https://barcodebookscanner.firebaseio.com/Users/\(firebaseUserUID)/")
        let usersBooksRef = ref.child("books")
        
        guard let isbn13 = values["isbn13"] as? String else { print("'isbn13' couldn't safely convert to type 'String'"); return }
        guard let isbn10 = values["isbn10"] as? String else { print("'isbn10' couldn't safely convert to type 'String'"); return }
        
         // To avoid an empty books-child 'title' in our Firebase database,
        // we check if any of the isbn values are empty. If both of them are empty we raise an error
        
        var scannedBookRef = usersBooksRef.child(isbn13)

        
        guard (!(isbn10.isEmpty) || !(isbn13.isEmpty)) else {
            //If isbn values are empty we do not want to update our Firebase database. We inform the user.
            presentISBNScanningError(); return
        }
        
        // Checks if 'isbn13' is empty, we do not need to check-and-set 'isbn10' because we already set 'usersBooksRef's' child
        if !(isbn13.isEmpty) {
            scannedBookRef = usersBooksRef.child(isbn10)
        }
        
        // We have a non-empty isbn value and can update it's reference' child values
        scannedBookRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                self.updateChildValuesErrorAlert()
                print("error occored");return
            }
            
            
        }
        
        
        print("Scan and network calls were succesful")
        
        let bookDetailVC = BookDetailViewController()
        let bookDetailVCNavigationController: UINavigationController = UINavigationController(rootViewController: bookDetailVC)
        
        present(bookDetailVCNavigationController, animated: true, completion: nil)

    }
    
    
    
        
    func updateChildValuesErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "An error occured. Try agian", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
