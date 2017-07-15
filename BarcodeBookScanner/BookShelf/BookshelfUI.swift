
//
//  DropDownInBookShelf.swift
//
//
//  Created by CarlJohan on 09/07/2017.
//
//

import Foundation
import UIKit
import AZDropdownMenu
import CoreData

extension BookShelfCV {
    
    
    override func viewDidLayoutSubviews() {
        
        let textViewContentSize = emptyBookshelfTextView.sizeThatFits(emptyBookshelfTextView.bounds.size)
        
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.8, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textViewContentSize.width).isActive = true
        NSLayoutConstraint(item: emptyBookshelfTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: textViewContentSize.height).isActive = true
        
        NSLayoutConstraint(item: emptyBookshelfScannerImage, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyBookshelfScannerImage, attribute: .top, relatedBy: .equal, toItem: emptyBookshelfTextView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    
    func showDropdown() {
        dropDownView?.showMenuFromRect(CGRect(x: 0, y: 70, width: 0, height: 0))
        if self.dropDownView!.isDescendant(of: collectionView) { self.dropDownView?.hideMenu() }
    }
    
    
    
    func setupEmptyBookshelfUIView() {
        
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
        
        collectionView.addSubview(emptyBookshelfTextView)
        collectionView.addSubview(emptyBookshelfScannerImage)
        
    }
    
    func removeBookFromBookshelf() {
        
        
    }
    
    func setupNavBarItem() {
        
        // Setup of the navigation bar
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 64))
        
        
        let sortButton = UIBarButtonItem(image: UIImage(named: "FilterIcon"), style: .plain, target: self, action: #selector(showDropdown))
        
        navItem.rightBarButtonItem = sortButton
        navItem.leftBarButtonItem = editButtonItem
        
        
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)
    }
    
    func setupDropDownView() {
    
        // Setup of the DropDownView
        dropDownView = AZDropdownMenu(titles: titles)
        dropDownView!.itemAlignment = .right
        dropDownView!.cellTapHandler = { [weak self] (indexPath: IndexPath) -> Void in
            
            self?.booksInCV.removeAll()
            
            if indexPath[1] < (self?.titles.count)! - 1 {
                self?.loadBookshelf(bookshelfID: (self?.bookshelfs[indexPath[1]].id)!)
                self?.navItem.title = self?.titles[indexPath[1]]
                
            } else if indexPath[1] == (self?.titles.count)! - 1 {
                self?.coreDataArray()
                self?.navItem.title = self?.titles[indexPath[1]]
            }
        }

    
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        switch editing {
        case true : break
        case false:
            
            let selectedIndexPaths = collectionView.indexPathsForSelectedItems
            
            let index = bookshelfs.index(where: { (bookshelf) -> Bool in
                bookshelf.title == navItem.title
            })
            
            if index != nil {
                print("Fis")
                print("Index:", index)
                // We reverse it to make sure the deleted item's indexPath is less than the previous item
                for indexPath in selectedIndexPaths!.reversed() {
                    let book = collectionView.cellForItem(at: indexPath) as! BookCell
                    let bookID = book.associatedConvenienceBook?.bookID
                    
                    collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: [indexPath])
                        self.booksInCV.remove(at: indexPath[1])
                    })
                    
                    GoogleBooksClient.sharedInstance.postToBookshelf(BookshelfID: self.bookshelfs[index!].id!, bookID: bookID!, add: false)
                }
                return
            }
            
            
//            fuckfuck()
            
            print("Deleting a core data book")
//            DispatchQueue.main.async {
                for indexPath in selectedIndexPaths!.reversed() {
                    let bookToDelete = self.appDelegate.stack.context.object(with: self.downloadedBookInCV[indexPath.item].objectID)
                    print("Book to delete:", bookToDelete)
                    print("IndexPath:", indexPath)
                    
                    self.collectionView.performBatchUpdates({
                        
                        self.appDelegate.stack.context.delete(bookToDelete)
                        self.booksInCV.remove(at: indexPath.item)
                        self.collectionView.deleteItems(at: [indexPath])
                        
                    })
                    
                }
//            }

            
            // slette 'bookToDelete', og fikse 'fatal error: Index out of range' hvis man skifter bookshelf inden alle billeder er downloadet
            
            print("lort")
        }
    }
    
        
    func deleteSelectedObject() {
        let itemIndexPaths = collectionView.indexPathsForSelectedItems!
        var selectedObjectsFromObjectID = [NSManagedObject]()
        
        
        for indexPath in itemIndexPaths {
            //            let cell = photosCollectionView.cellForItem(at: indexPath) as! PhotoCell
            //            guard let photoFromCell = cell.associatedPhoto else { print("cell.associatedPhoto was not succesfully unwrapped"); return }
            
            let bookToDelete = self.appDelegate.stack.context.object(with: self.downloadedBookInCV[indexPath.item].objectID)
            
//            let object = appDelegate.stack.context.object(with: bookToDeletesID)
            selectedObjectsFromObjectID.append(bookToDelete)
            
        }
        let managedObjectsToDeleteAsNSSet = NSSet(array: selectedObjectsFromObjectID )
        
        
        
        self.collectionView.performBatchUpdates({
            
            self.collectionView.deleteItems(at: itemIndexPaths)
//            self.appDelegate.stack.context.delete(managedObjectsToDeleteAsNSSet)
//            self.collectionViewPin?.removeFromPhotos(managedObjectsToDeleteAsNSSet)
            
        }) { (true) in
            do { try self.appDelegate.stack.saveContext()
            } catch { print("An error occured trying to save core data") }
        }

    
    
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
        switch type {
        case .delete:
            print("deleted an object")
//            collectionView.performBatchUpdates({
//                self.collectionView.deleteItems(at: [indexPath!])
//            })
        case .insert:
            print("inserted an object")
        case .move:
            print("moved an object")
        case .update:
            print("updated an object")
            self.coreDataArray()
            //            if let index = indexPath, let cell = photosCollectionView.cellForItem(at: index) as? PhotoCell {
            //                configureCell(index, cell)
            //            }
            
        }
    }
    
    func coreDataArray() {
        
        for fetchedObject in downloadedBookInCV {
            var convenienceBook = ConvenienceBook()
            
            convenienceBook.title = fetchedObject.bookTitle!
            convenienceBook.smallestThumbnail = UIImage(data: fetchedObject.bookCoverAsData! as Data)
            convenienceBook.largestThumbnail = UIImage(data: fetchedObject.bookCoverAsData! as Data)
            convenienceBook.isbn13 = String(fetchedObject.isbn13)
            convenienceBook.isThumbnailAvailable = true
            
            booksInCV.append(convenienceBook)
        }
        collectionView.reloadData()
        
    }
    
}
