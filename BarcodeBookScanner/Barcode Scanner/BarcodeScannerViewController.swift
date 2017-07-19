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
    let bookDetailVC = BookDetailViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("BarcodeScannerViewController did load")
        
        // Sets up the camera, and barcode scanner
        setupCamera()
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized {
            // Already Authorized
            print("Camera is already authorized")
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                // User granted access.
                print("Granted access")
                if granted {
                    print("Granted access == true ")
//                    self.checkAndAddInput()
//                    if !(self.session.isRunning) {
//                        self.checkAndAddOutput()
//                        self.session.startRunning()
//                    }
                    self.checkAndAddInput()
                    self.checkAndAddOutput()
                    
                    if !(self.session.isRunning) {
//                        self.checkAndAddOutput()
                        self.session.startRunning()
                    }
                    
//                    self.setupCamera()
                }
            })
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            // If session is not running
            self.checkAndAddOutput()
            if !(self.session.isRunning) {
                self.session.startRunning()
                
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        DispatchQueue.main.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }
    
    func updateChildValues(convenienceBook: ConvenienceBook) {
        guard let firebaseUserUID = Auth.auth().currentUser?.uid else { print("Current Firebase user UID == nil");
            errorOccuredErrorAlert(); return
        }
        let ref = Database.database().reference(fromURL: "https://barcodebookscanner.firebaseio.com/Users/\(firebaseUserUID)/")
        let usersBooksRef = ref.child("books")
        
        let values = convenienceBook.getAllNonEmptyValues()
        
        guard let isbn13 = values["isbn13"] else { print("'isbn13' couldn't safely convert to type 'String'")
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
