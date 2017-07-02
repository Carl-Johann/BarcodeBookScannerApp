//
//  BookShelf.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 27/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseStorage
import FirebaseDatabase

class BookShelf: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {//, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var lort = [[String:AnyObject]]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("Access Token: \(GIDSignIn.sharedInstance().currentUser.authentication.accessToken!)")
        
        // Load the users eBooks
        loadBookshelf()
    }
    
    override func viewDidLoad() {
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(handleCameraButtonAction))
        navigationItem.rightBarButtonItem = cameraButton
//        navigationItem.rightBarButtonItem = cameraButton
        
        
        let button = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        button.backgroundColor = UIColor.cyan
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        
    }

    func handleCameraButtonAction() {
//        let sb = storyboard
//        let lort = sb?.instantiateViewController(withIdentifier: "barcodeNavigationController")
//        present(, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        let barcodeVC = self.storyboard!.instantiateViewController(withIdentifier: "barcodeScannerViewController") as! BarcodeScannerViewController
        self.navigationController!.pushViewController(barcodeVC, animated: true)

    }
    
    func buttonAction() {
        
        self.collectionView!.reloadData()
        
        
    }
    
    func loadBookshelf() {
        
        GoogleBooksClient.sharedInstance.getSpecificBookShelfFromUser(BookshelfID: 7) { (success, items) in
            if success == false {
                // RAISE ERROR
                return
            }
            
            
            for book in items {
                print("A book")
                self.lort.append(book)
            }
            
            DispatchQueue.main.async { self.collectionView!.reloadData() }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lort.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCellID", for: indexPath) as! BookCell
        let bookForIndexPath = lort[indexPath[1]]
        
        // the users current database reference url. By using this reference, you are on level with the values 'email' and 'name'
//        guard let firebaseUserUID = Auth.auth().currentUser?.uid else { print("Current Firebase user UID == nil"); return cell }
//        let ref = Database.database().reference(fromURL: "https://barcodebookscanner.firebaseio.com/Users/\(firebaseUserUID)/")
//        
//        ref.observe(.value, with: { (snapshot) in
//            print(snapshot.value!)
//            let lort = snapshot.value as! [AnyHashable: Any]
//            
//            
////            let lort = snapshot as [AnyHashable: Any]
////            print(snapshot["email"])
//        })

        
//
//        
//        
//
//        func purgeOutstandingWrites()        
//        $var isPersistenceEnabled: Bool { get set }
//        
//        
//        
//        
//        ref.child("books")
//        
//        let values = [
//            "title": ,
//            "author": ,
//            "description": ,
//            "ISBN_13": ,
//            "ISBN_10": ,
//            "purchaseLink": ,
//            "currencyCode": ,
//            "amountInMicros":
//        ]
//        
//        ref.updateChildValues(<#T##values: [AnyHashable : Any]##[AnyHashable : Any]#>) { (error, reference) in
//            
//        }
//        
        //        cell.bookCoverImage
        
        return cell
    }
    
}
