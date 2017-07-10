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
import AZDropdownMenu

class BookShelf: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "cellIdentifier"
    
    let titles = ["Favorites", "Purchased", "To Read", "Reading Now", "Have Read", "Reviewed", "Recently Viewed", "My eBooks", "Books For You"]
    let dropDownTableView = UITableView()
    var dropDownView: AZDropdownMenu?
    var emptyBookshelfTextView = UITextView()
    var emptyBookshelfView = UIView()
    var emptyBookshelfScannerImage = UIImageView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var booksInCV = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        // Load the users books
        //loadBookshelf(bookshelfID: 7)
        
        // Setup of the navigation bar
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 64))
        let navItem = UINavigationItem(title: "My eBooks")
        
        let sortButton = UIBarButtonItem(image: UIImage(named: "FilterIcon"), style: .plain, target: self, action: #selector(showDropdown))
        navItem.rightBarButtonItem = sortButton
        
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
        
        // Setup of the DropDownView
        dropDownView = AZDropdownMenu(titles: titles)
        dropDownView?.itemAlignment = .right
        dropDownView?.cellTapHandler = { indexPath -> Void in
            navItem.title = self.titles[indexPath[1]]
            self.loadBookshelf(bookshelfID: indexPath[1])
        }
        
        // Setup of the emptyBookshelfTextView
        emptyBookshelfTextView.isUserInteractionEnabled = false
        emptyBookshelfTextView.font = UIFont(name: "IowanOldStyle-Roman", size: 21)
        emptyBookshelfTextView.text = "Your bookshelf is empty! \nScan some books!"
        emptyBookshelfTextView.textAlignment = .center
        emptyBookshelfTextView.translatesAutoresizingMaskIntoConstraints = false
        emptyBookshelfTextView.alpha = 0
        
        emptyBookshelfScannerImage.alpha = 0
        emptyBookshelfScannerImage.translatesAutoresizingMaskIntoConstraints = false
        emptyBookshelfScannerImage.image = UIImage(named: "MediumScannerIcon")!
        

    }
    
    override func viewDidLayoutSubviews() {
        let textViewContentSize = emptyBookshelfTextView.sizeThatFits(emptyBookshelfTextView.bounds.size)
        
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.8, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textViewContentSize.width).isActive = true
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant:textViewContentSize.height).isActive = true
        
        NSLayoutConstraint(item: emptyBookshelfScannerImage, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyBookshelfScannerImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    
    func showDropdown() {
        dropDownView?.showMenuFromRect(CGRect(x: 0, y: 70, width: view.frame.width, height: getMenuHeight()))
        if (self.dropDownView?.isDescendant(of: self.view) == true) {
            self.dropDownView?.hideMenu()
        } else {
            self.dropDownView?.showMenuFromView(self.view)
        }
    }
    
    
    
    func loadBookshelf(bookshelfID: Int) {
        booksInCV.removeAll()
//             print(12312323)
        GoogleBooksClient.sharedInstance.getSpecificBookShelfFromUser(BookshelfID: bookshelfID) { (success, succesDescription, items) in
            print(444)
            if success == false {
                self.presentBarcodeErrorMessage(errorMessage: succesDescription)
                return
            }
            guard let books = items else {
                DispatchQueue.main.async { self.collectionView.reloadData() }
                return
            }
            
            // overcome all obstacles - andy fris... Hvis books downloaded == 0, skal cv være tom, og vise et label der siger 'No books in bookshelf' og måske vise et uiimage fra Flatico
            for book in books {
                self.booksInCV.append(book)
            }
            
            DispatchQueue.main.async { self.collectionView.reloadData() }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if booksInCV.count == 0 {
            emptyBookshelfTextView.alpha = 1
            emptyBookshelfScannerImage.alpha = 1
            return booksInCV.count
        }
        emptyBookshelfTextView.alpha = 0
        emptyBookshelfScannerImage.alpha = 0
        return booksInCV.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCellID", for: indexPath) as! BookCell
        //        let bookForIndexPath = lort[indexPath[1]]
        
        
        return cell
    }
    
    
    
    
    
    func getMenuHeight() -> CGFloat{
        let itemsHeight = (dropDownView?.itemHeight)! * titles.count
        
        return CGFloat(min(itemsHeight, Int(view.frame.size.height)))
    }
    
    func presentBarcodeErrorMessage(errorMessage: String) {
        let alert = UIAlertController(title: "Error occured", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}
