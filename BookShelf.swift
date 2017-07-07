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
//        print("BookShelf will appear")
    }
    
    override func viewDidLoad() {
//        print("BookShelf did load")
        
        // Load the users books
        loadBookshelf()
        
        
        
        
        
        let button = UIButton(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        button.backgroundColor = UIColor.cyan
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        print("BookShelf did disappear")
    }

//    func handleCameraButtonAction() {
////        let sb = storyboard
////        let lort = sb?.instantiateViewController(withIdentifier: "barcodeNavigationController")
////        present(, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//        let barcodeVC = self.storyboard!.instantiateViewController(withIdentifier: "barcodeScannerViewController") as! BarcodeScannerViewController
//        self.navigationController!.pushViewController(barcodeVC, animated: true)
//
//    }
    
    func buttonAction() {
        print("Clicked button")
        self.collectionView!.reloadData()
        
    }

    
    func loadBookshelf() {
        print(1)
        GoogleBooksClient.sharedInstance.getSpecificBookShelfFromUser(BookshelfID: 7) { (success, items) in
            if success == false {
                // RAISE ERROR
                return
            }
            
            
            
            for book in items {
                self.lort.append(book)
            }
            print("Number of books downloaded: \(self.lort.count)")
            DispatchQueue.main.async { self.collectionView!.reloadData() }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lort.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCellID", for: indexPath) as! BookCell
        let bookForIndexPath = lort[indexPath[1]]
       
        
        return cell
    }
    
    
    
}
