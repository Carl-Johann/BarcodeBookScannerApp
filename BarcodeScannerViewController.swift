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
import CoreData

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("BarcodeScannerViewController did load")
        // Sets up the camera, and barcode scanner
        setupCamera()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            // If session is not running
            
            if !(self.session.isRunning) {
                self.session.startRunning()
                
                self.checkAndAddOutput()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        DispatchQueue.main.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }
    
    
    

    func getInformationFromScannedBook(items: [[String : AnyObject]]) -> ConvenienceBook {
        
        var scannedBook = ConvenienceBook()
        
        // Safely unwraps the desired values from the JSON gotten from scanning the barcode, and calling the 'getBookInformationFromBarcode' function
        for item in items {
            guard let volumeInfo = item["volumeInfo"] as? [String : AnyObject] else { print("volumeInfo wasn't accessible in item"); errorOccuredErrorAlert(); return scannedBook  }
            guard let bookTitle = volumeInfo["title"] as? String else { print("'title' wasn't accessible in 'volumeInfo'"); self.errorOccuredErrorAlert(); return scannedBook }
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
    
    
    
    
    func updateChildValues(convenienceBook: ConvenienceBook) {
        guard let firebaseUserUID = Auth.auth().currentUser?.uid else { print("Current Firebase user UID == nil");
            errorOccuredErrorAlert(); return
        }
        let ref = Database.database().reference(fromURL: "https://barcodebookscanner.firebaseio.com/Users/\(firebaseUserUID)/")
        let usersBooksRef = ref.child("books")
        
        let values = convenienceBook.getAllValues()
        
        guard let isbn13 = values["isbn13"] else { print("'isbn13' couldn't safely convert to type 'String'");
            errorOccuredErrorAlert(); return
        }
        let scannedBookRef = usersBooksRef.child(isbn13)
    
        scannedBookRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                self.errorOccuredErrorAlert()
                print("error occored updating child values in Firebase Database"); return
            }
        }
        
    }
    
    
    
        
    func errorOccuredErrorAlert() {
        print("errorOccuredErrorAlert called")
        let alert = UIAlertController(title: "Error", message: "An error occured. Try agian", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
