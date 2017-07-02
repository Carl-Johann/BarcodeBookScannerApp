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

extension BarcodeScannerViewController {
    
    //    var session: AVCaptureSession!
    //    var previewLayer: AVCaptureVideoPreviewLayer!
    
    func setupCamera() {
        
        // Create a session object.
        session = AVCaptureSession()
        let metadataOutput = AVCaptureMetadataOutput()
        
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
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            let rectOfInterest = CGRect(x: 160.0, y: 200.0, width: 200.0, height: 21.0)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code]
            //metadataOutput.rectOfInterest = rectOfInterest
            
            session.commitConfiguration()
        } else {
            print("Couldn't add output")
        }
        
        
        // Add previewLayer and have it show the video data.
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        let cameraFrame = view.layer.bounds
        cameraFrame.insetBy(dx: 0, dy: navigationController!.navigationBar.frame.height)
        previewLayer.frame = cameraFrame
        view.layer.addSublayer(previewLayer)
        
        // Begin the capture session.
        session.startRunning()
        
        
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
            session.stopRunning()
            
            
        }
    }
    
    
    
    
    func barcodeDetected(_ code: String) {
        
        // trimming the detected code
        guard let trimmedCode = Int(code.trimmingCharacters(in: NSCharacterSet.whitespaces)) else {
            print("Trimming of scanned code failed")
            return
        }
        
        // making an API call with the retrived code
        DispatchQueue.main.async {
            GoogleBooksClient.sharedInstance.getBookInformationFromBarcode(trimmedCode) { (succes, data) in
                
                // Check for success
                guard (succes != false) else { print("Succes value from 'getBookInformationFromBarcode' == false"); return }
                
                // Safely unwrap the data gotten from the API call
                guard let items = data["items"] as? [[String : AnyObject]] else { print("Couldn't access 'items' in data"); return }
                print(items)
                let values = self.getInformationFromScannedBook(items: items)
                self.updateChildValues(values: values)
            }
        }
    }

    
    
    
    
// MARK: - Alert functions
    func scanningNotPossible() {
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func presentISBNScanningError() {
        let alert = UIAlertController(title: "Error occured",
            message: "Scan agian, if the error persists, book is not properly supported and can't be scanned",
            preferredStyle: .alert)
        
        print("ERROR: Both isbn values were empty")
        present(alert, animated: true, completion: nil)
    }
    
    
}
