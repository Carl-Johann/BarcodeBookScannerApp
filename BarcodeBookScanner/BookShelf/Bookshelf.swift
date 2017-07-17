//
//  BookShelf.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 27/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

//                                  addVolume
// Purchased        -- | 403 | 403 | 403 | 403 | 403 | 403 | 403 |
// Reviewed         -- | 204 | 204 | 204 | 204 | 204 | 204 | 204 |
// Recently viewed  -- | 204 | 204 | 204 | 204 | 204 | 204 | 204 |
// Browsing history -- | 204 | 204 | 204 | 204 | 204 | 204 | 204 |
// Favorites        -- | 403 | 403 | 403 | 403 | 403 | 403 | 403 |
// Reading now      -- | 403 | 403 | 403 | 403 | 403 | 403 | 403 |
// To read          -- | 204 | 204 | 204 | 204 | 204 | 204 | 403 |
// Have read        -- | 403 | 403 | 403 | 403 | 403 | 403 | 403 |
// Books for you    -- | 403 | 403 | 403 | 403 | 403 | 403 | 403 |
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseStorage
import FirebaseDatabase
import AZDropdownMenu
import CoreData

class BookShelfCV: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {    
    
    // Når appen åbner skal vi kigge i Firebase for at se om brugeren har scannet bøger.    
    // Der går for lang tid fra man trykker på scanned books til at man kommer ind på 'DetailVC'
    // bøger forsvinder når man scroller væk fra dem
    
    // FIXED
    // Nogle gange når man scanner kommer billedet ikke med
    // Slette coreData - sletter alt, ikke bare den valgte...
    // Nogle gange når man trykker på scanned books er der duplicates
    // scanned books viser bøger der ikke er scannet
    // Scanned books skal reloade
    // Navne og titler matcher ikke op - titlen passer, billedet der ikke gør - bliver 'booksInCV' ikke tømt? der er rester fra tideligere bookshelfs
    // Møder nil nogle gange når man scanner bog
    // Få brugerens reoler og add dem til tiles?
    // sletter ikke alle de rigtige celler i 'detailVC'
    // Fikse 'fatal error: Index out of range' hvis man skifter bookshelf inden alle billeder er downloadet
    // Kameraet åbner ikke - når man åbner appen for første gang, fordi den prøver at adde input, men ikke har fået lov endnu
    // Når man sletter / adder bogen til alle reoler får man fejlen 'fatal error: Index out of range' - hvis man ikke gør det en efter en
    // Slette det tomme plads når alle 'AddTo' celler er væk
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var titles: [String] = []
    
    var dropDownView: AZDropdownMenu?
    var emptyBookshelfTextView = UITextView()
    let emptyBookshelfScannerImage = UIImageView()
    var isInitailSetupDone = false

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
        
        collectionView.contentInset = UIEdgeInsets(top: 3, left: 3, bottom: 0, right: 3)
        collectionView.allowsMultipleSelection = true
        
        // Setup of the 'emptyBookshelfTextView' and 'emptyBookshelfScannerImage'
        setupEmptyBookshelfUIView()
        
        // Setup of the 'navBar' and navigation items
        setupNavBarItem()
        
        // Load the bookshelfs
        loadBookshelfs()
        
        do { try fetchedResultsController.performFetch()
        } catch { print("Failed to initialize FetchedResultsController: \(error)") }
        
        
        downloadedBookInCV.append(contentsOf: fetchedResultsController.fetchedObjects!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        print("BookShelfCV will appear")
        if navItem.title == "Scanned books" {
//            print("Bookshelf is 'Scanned books'")
            coreDataArray()
        }
        
//        do { try fetchedResultsController.performFetch()
//        } catch { print("Failed to initialize FetchedResultsController: \(error)") }
        
//        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        print("BookShelfCV did disappear")
        
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
            
            // We add the 'scanned boook' element so the user has a place to click to show scanned books, 
            // since it's not included in the 'Google Books API'
            self.titles.append("Scanned books")
            
            let largestBook = self.bookshelfs.max(by: { (book1 , book2) -> Bool in
                return book1.bookCount < book2.bookCount
            })
            
            DispatchQueue.main.async {
                self.navItem.title = largestBook?.title
                self.setupDropDownView()
            }
            self.loadBookshelf(bookshelfID: (largestBook?.id!)!)
        }
    }
    
    
    func loadBookshelf(bookshelfID: Int) {
        booksInCV.removeAll()
        DispatchQueue.main.async { self.collectionView.reloadData() }
        
        GoogleBooksClient.sharedInstance.getSpecificBookShelfFromUser(BookshelfID: bookshelfID) { (success, succesDescription, items) in
            if success == false {
                DispatchQueue.main.async { self.navItem.rightBarButtonItem?.isEnabled = true }
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
            DispatchQueue.main.async { self.navItem.rightBarButtonItem?.isEnabled = true }
            print("instantiated download for all books")
        }
    }
    
        
    
    func initiateImageDownload(convenienceBook: ConvenienceBook, index: Int) {
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.sync {
            
            let smallestThumbnail = convenienceBook.getSmallestThumbnail()
            guard !(smallestThumbnail.isEmpty) else { return }
            
            
            let url = URL(string: smallestThumbnail)
            let data = try? Data(contentsOf: url!)
            let imageFromURL = UIImage(data: data!)
            
            
            DispatchQueue.main.async {
                
                self.booksInCV[index].smallestThumbnail = imageFromURL
                self.booksInCV[index].isThumbnailAvailable = true
                self.booksInCV[index].title = convenienceBook.title
                
                
                // Since we can only update the cells that are created and therefore visible,
                // we check if convenienceBook having it's download initiated's index is less than the visible amount of cells
                guard index < self.collectionView.visibleCells.count else { return }
                
                let bookCell = self.collectionView.visibleCells[index] as! BookCell // - får den forkerte celle? billedet matcher ikke
                
                bookCell.bookCoverImage.image = imageFromURL
                bookCell.bookCoverImage.alpha = 1
                bookCell.bookTitle.text = convenienceBook.title
                bookCell.loadingIndicator.stopAnimating()
                bookCell.associatedConvenienceBook?.isThumbnailAvailable = true
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
