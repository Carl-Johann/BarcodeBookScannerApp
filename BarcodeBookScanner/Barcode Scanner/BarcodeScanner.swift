//
//  BarcodeScanner.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 02/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseAuth
import CoreData

extension BarcodeScannerViewController {
    
    func setupCamera() {
        
        // Create a session object.
        session = AVCaptureSession()
        
        
        // Set the captureDevice.
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // Create input object.
        let videoInput: AVCaptureDeviceInput?
        do { videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch { print("ERROR: \(error)"); return }
        
        // Add input to the session.
        if session.canAddInput(videoInput!) {
            session.addInput(videoInput!)
        } else {
            scanningNotPossible()
        }
        
        checkAndAddOutput()
        
        // Add previewLayer and have it show the video data.
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        // Begin the capture session.
        DispatchQueue.main.async { self.session.startRunning() }
        
        
    }
    
    func checkAndAddOutput() {
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code]
            session.commitConfiguration()
        } else {
            print("Couldn't add output")
        }
        
        
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Get the first object from the metadataObjects array.
        if let barcodeData = metadataObjects.first {
            // Turn it into machine readable code
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
            if let readableCode = barcodeReadable {
                // Send the barcode as a string to barcodeDetected()
                barcodeDetected(readableCode.stringValue);
            }
            
            // Vibrate the device to give the user some feedback.
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Avoid a very buzzy device.
            session.removeOutput(session.outputs.first as! AVCaptureOutput)
            
            
            
        }
    }
    
    
    
    
    func barcodeDetected(_ code: String) {
        
        // trimming the detected code
        guard let trimmedCode = Int(code.trimmingCharacters(in: NSCharacterSet.whitespaces)) else {
            print("Trimming of scanned code failed"); return
        }
        
        // making an API call with the retrived code
        DispatchQueue.main.async {
            GoogleBooksClient.sharedInstance.getBookInformationFromBarcode(trimmedCode) { (succes, data, errorMessage) in
                // Check for success
                if succes == false {
                    self.presentBarcodeErrorMessage(errorMessage: errorMessage)
                    return
                }
                
                // Safely unwrap the data gotten from the API call
                guard let items = data["items"] as? [[String : AnyObject]] else { print("Couldn't access 'items' in data");
                    self.errorOccuredErrorAlert(); return }
                print(items)
                
                
                var convenienceBook = GoogleBooksClient.sharedInstance.getConvenienceBookFromScannedBook(items: items)
                self.updateChildValues(convenienceBook: convenienceBook)
                guard let firebaseUserUID = Auth.auth().currentUser?.uid else { print("Current Firebase user UID == nil"); return }
                
                
                
                let bookDetailVC = BookDetailViewController()
                
                
                
                // Check if a Book managedObject already exsits
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
                let predicate = NSPredicate(format: "isbn13 == %@", argumentArray: [convenienceBook.isbn13])
                fetchRequest.predicate = predicate
                let fetchResults = try! self.appDelegate.stack.context.fetch(fetchRequest) as? [Book]
                
                // Checls if the book has been scanned before
                if fetchResults!.count == 0 {
                    print("Book hadn't been scanned before, creating Book instance in CoreData")
                    
                    
                    // Create Book managedObject and assign values accordingly
                    let bookFromBarcode = Book(context: self.appDelegate.stack.context)
                    bookFromBarcode.bookTitle = convenienceBook.title
                    bookFromBarcode.firebaseUID = firebaseUserUID
                    
                    
                    bookFromBarcode.isbn13 = Int64(convenienceBook.isbn13)!//
                    
                    
                    do { try self.appDelegate.stack.saveContext()
                    } catch { print("An error occured trying to save core data, after creating book") }
                    
                    
                    
                    
                    
                    let thumbnailToDownload = convenienceBook.getBiggestThumbnail()
                    if !(thumbnailToDownload.isEmpty) {
                        print("Thumbnail to download is not empty")
                        
                        
                        // The contents of the url are retrieved on a concurrent que to avoid errors with 'backthreading'
                        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
                        concurrentQueue.sync {
                            
                            let url = URL(string: thumbnailToDownload)
                            let data = try? Data(contentsOf: url!)
                            let imageFromURL = UIImage(data: data!)
                            
                            convenienceBook.largestThumbnail = imageFromURL
                            convenienceBook.isThumbnailAvailable = true
                            bookFromBarcode.bookCoverAsData = UIImagePNGRepresentation(imageFromURL!) as NSData?
                            
                            do { try self.appDelegate.stack.saveContext() }
                            catch { print("ERROR: \(error)") }
                            
                            
                        }
                    }
                    
                }
                
                bookDetailVC.convenienceBook = convenienceBook
                let bookDetailVCNavigationController: UINavigationController = UINavigationController(rootViewController: bookDetailVC)
                self.present(bookDetailVCNavigationController, animated: true, completion: nil)
            }
        }
    }
    
    
    func imageFromURL(book: Book, urlString: String) {
        print("imageFromURL was called")
        // The contents of the url are retrieved on a concurrent que to avoid errors with 'backthreading'
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.sync {
            
            let url = URL(string: urlString)
            let data = try? Data(contentsOf: url!)
            let imageFromURL = UIImage(data: data!)
            
            
            book.bookCoverAsData = UIImagePNGRepresentation(imageFromURL!) as NSData?
            
            do { try self.appDelegate.stack.saveContext() }
            catch { print("ERROR: \(error)") }
                        
        }
        
    }
    
    
    
    // MARK: - Alert's and supporting functions
    func scanningNotPossible() {
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func presentBarcodeErrorMessage(errorMessage: String) {
        let alert = UIAlertController(title: "Error occured", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
            self.checkAndAddOutput()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentISBNScanningError() {
        let alert = UIAlertController(title: "Error occured",
                                      message: "Scan agian, if the error persists, book is not properly supported and can't be scanned",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        print("ERROR: An isbn value is empty")
        present(alert, animated: true, completion: nil)
    }
    
    
}
