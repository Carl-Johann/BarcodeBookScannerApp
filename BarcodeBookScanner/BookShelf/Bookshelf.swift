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
import CoreData

class BookShelfCV: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var titles: [String] = []
    
    var dropDownView: AZDropdownMenu?
    var emptyBookshelfTextView = UITextView()
    let emptyBookshelfScannerImage = UIImageView()
    var isInitailSetupDone = false
    
//    var fetchRequest: NSFetchRequest<Book>?
//    var fetchedResultsController: NSFetchedResultsController<Book>?
    
    let navItem = UINavigationItem(title: "")
    @IBOutlet weak var collectionView: UICollectionView!
    
    var bookshelfs: [GoogleBookshelf] = [GoogleBookshelf]()
    var booksInCV: [ConvenienceBook] = [ConvenienceBook]()
    var downloadedBookInCV: [Book] = [Book]()
    
    
    lazy var fetchedResultsController = { () -> NSFetchedResultsController<Book> in
        
        let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
        fetchRequest.sortDescriptors = []
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    
    
    override func viewDidLoad() {
        // Load the users books
//        loadBookshelf(bookshelfID: 7)
        
        collectionView.contentInset = UIEdgeInsets(top: 3, left: 3, bottom: 0, right: 3)
        collectionView.allowsMultipleSelection = true
        
        // Setup of the 'emptyBookshelfTextView' and 'emptyBookshelfScannerImage'
        setupEmptyBookshelfUIView()
        
        // Setup of the 'navBar' and navigation items
        setupNavBarItem()
        
        // Load the bookshelfs
        loadBookshelfs()

        
        // Fetch the scanned book
//        fetchRequest = NSFetchRequest<Book>(entityName: "Book")
//        fetchRequest?.sortDescriptors = [ ]
        
//        let context = self.appDelegate.stack.context
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        do { try fetchedResultsController.performFetch()
        } catch { print("Failed to initialize FetchedResultsController: \(error)") }
        
        print("Number of Book's in fetchedResultsController:", (fetchedResultsController.fetchedObjects?.count)!)
        for fetchedObject in fetchedResultsController.fetchedObjects! { downloadedBookInCV.append(fetchedObject) }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("BookShelfCV will appear")
//        do { try fetchedResultsController?.performFetch()
//        } catch { print("Failed to initialize FetchedResultsController: \(error)") }
//        coreDataArray()
    }
    
    
    func loadBookshelfs() {
        GoogleBooksClient.sharedInstance.getAuthenticatedUsersBookshelfs { (succes, items) in
            if succes == false { self.presentErrorLoadingBookshelfs(); return }
            
            for item in items! {
                var bookshelf = GoogleBookshelf()
                guard let title = item["title"] as? String else { print("'title' wasn't available in 'item'"); return }
                guard let id = item["id"] as? Int else { print("'id' wasn't available in 'item'"); return }
                if let bookCount = item["volumeCount"] as? Int { bookshelf.bookCount = bookCount }
                
                bookshelf.id = id
                bookshelf.title = title
                
                self.titles.append(title)
                self.bookshelfs.append(bookshelf)
                
            }
            
            // We add the 'scanned boook' element so the user has a place to click to show scanned book, since it's not included in the Google Books API
            self.titles.append("Scanned books")
            
            DispatchQueue.main.async {
                self.navItem.title = self.bookshelfs[0].title
                self.setupDropDownView()
            }
            self.loadBookshelf(bookshelfID: self.bookshelfs[0].id!)
        }
        
    }
    
    
    func loadBookshelf(bookshelfID: Int) {
        booksInCV.removeAll()
        
        GoogleBooksClient.sharedInstance.getSpecificBookShelfFromUser(BookshelfID: bookshelfID) { (success, succesDescription, items) in
            if success == false {
                self.presentBarcodeErrorMessage(errorMessage: succesDescription); return
            }
            
            guard let books = items else { DispatchQueue.main.async { self.collectionView.reloadData() }; return }
            
            for bookItem in books {
                let convenienceBook = GoogleBooksClient.sharedInstance.getConvenienceBookFromScannedBook(items: [bookItem])
                self.booksInCV.append(convenienceBook)
            }
            
            self.isInitailSetupDone = true
            DispatchQueue.main.async { self.collectionView.reloadData() }
            
            for (index, convenienceBook) in self.booksInCV.enumerated() {
                self.initiateImageDownload(convenienceBook: convenienceBook, index: index)
            }
        }
    }
    
        
    
    func initiateImageDownload(convenienceBook: ConvenienceBook, index: Int) {
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.sync {
            
            let smallestThumbnail = convenienceBook.getSmallestThumbnail()
            if !(smallestThumbnail.isEmpty) {
                
                let url = URL(string: smallestThumbnail)
                let data = try? Data(contentsOf: url!)
                let imageFromURL = UIImage(data: data!)
                
                
                DispatchQueue.main.async {
                    
                    self.booksInCV[index].smallestThumbnail = imageFromURL
                    self.booksInCV[index].isThumbnailAvailable = true
                    
                    for cell in self.collectionView.visibleCells {
                        
                        let bookCell = cell as! BookCell
                        // Get the right cell
                        if bookCell.associatedConvenienceBook?.isbn13 == convenienceBook.isbn13 {
                            
                            bookCell.bookCoverImage.image = imageFromURL
                            bookCell.bookCoverImage.alpha = 1
                            bookCell.loadingIndicator.stopAnimating()
                            bookCell.associatedConvenienceBook?.isThumbnailAvailable = true
                        }
                    }
                }
            }
        }
    }
    
    
    func presentErrorLoadingBookshelfs() {
        let alert = UIAlertController(title: "Error occured", message: "Couldn't load bookshelfs", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try agian", style: .default, handler: { (action) in
            self.loadBookshelfs()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func presentBarcodeErrorMessage(errorMessage: String) {
        let alert = UIAlertController(title: "Error occured", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (action) in
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}
