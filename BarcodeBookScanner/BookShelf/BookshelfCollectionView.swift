//
//  BookshelfCollectionView.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 13/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit

extension BookShelfCV {
            
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let CVWidth = collectionView.contentSize.width
        let numberOfItemsPerRow: CGFloat = 2.0
        
        let itemSize = (CVWidth/numberOfItemsPerRow) - 3
        
        
        return CGSize(width: itemSize, height: itemSize * 1.5)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if booksInCV.count == 0 && isInitailSetupDone {
            emptyBookshelfTextView.alpha = 1
            emptyBookshelfScannerImage.alpha = 1
            return booksInCV.count
        }
        emptyBookshelfTextView.alpha = 0
        emptyBookshelfScannerImage.alpha = 0
        return booksInCV.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch self.isEditing {
        case true:
            let selectedCell = collectionView.cellForItem(at: indexPath)
            selectedCell?.alpha = 1
        case false:
            break
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.isEditing {
        case true:            
            let selectedCell = collectionView.cellForItem(at: indexPath)
            selectedCell?.alpha = 0.5
        
        
        
        
        
        case false:
            DispatchQueue.main.async {
                let selectedCell = collectionView.cellForItem(at: indexPath) as! BookCell
                let selectedCellConvenienceBook = selectedCell.associatedConvenienceBook
                
                let bookDetailVC = BookDetailViewController()
                
                if self.navItem.title == "Scanned books" {
                    DispatchQueue.main.async {
                        GoogleBooksClient.sharedInstance.getBookInformationFromBarcode(Int(selectedCellConvenienceBook!.isbn13)!) { (succes, data, errorMessage) in
                            // Check for success
                            if succes == false {
                                self.presentBarcodeErrorMessage(errorMessage: errorMessage); return
                            }
                            // Core Data object
                            
                            guard let items = data["items"] as? [[String : AnyObject]] else { print("Couldn't access 'items' in data");
                            self.presentBarcodeErrorMessage(errorMessage: "Internal error. Try agian later"); return }
                        
                            var convenienceBook = GoogleBooksClient.sharedInstance.getConvenienceBookFromScannedBook(items: items)
                            
                            convenienceBook.title = (selectedCellConvenienceBook?.title)!
                            convenienceBook.smallestThumbnail = selectedCellConvenienceBook?.smallestThumbnail
                            convenienceBook.largestThumbnail = selectedCellConvenienceBook?.largestThumbnail
                            convenienceBook.isbn13 = (selectedCellConvenienceBook?.isbn13)!
                            convenienceBook.isThumbnailAvailable = true
                            
                            bookDetailVC.convenienceBook = convenienceBook
                            
                            var titlesToTransfer = self.titles
                            titlesToTransfer.removeLast()
                            bookDetailVC.titles = titlesToTransfer
                            
                            let bookDetailVCNavigationController: UINavigationController = UINavigationController(rootViewController: bookDetailVC)
                            self.present(bookDetailVCNavigationController, animated: true, completion: nil)
                        }
                    }
                    
                } else if self.navItem.title != "Scanned books" {
                    bookDetailVC.convenienceBook = selectedCellConvenienceBook
                    
                    var titlesToTransfer = self.titles
                    titlesToTransfer.removeLast()
                    bookDetailVC.titles = titlesToTransfer
                    let bookDetailVCNavigationController: UINavigationController = UINavigationController(rootViewController: bookDetailVC)
                    self.present(bookDetailVCNavigationController, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! BookCell
        let bookAtIndexPath = booksInCV[indexPath.item] as ConvenienceBook
        cell.associatedConvenienceBook = bookAtIndexPath
        
        cell.backgroundColor = .lightGray
        cell.loadingIndicator.startAnimating()
        cell.bookCoverImage.alpha = 0
        
        cell.bookTitle.text = ""
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.cornerRadius = 3
        cell.bookTitle.textContainer.lineBreakMode = .byTruncatingTail
        cell.bookTitle.font = UIFont(name: "TimesNewRomanPSMT", size: 21)
        cell.bookTitle.layer.borderWidth = 1
        cell.bookTitle.layer.borderColor = UIColor.black.cgColor
        cell.bookTitle.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        cell.bookTitle.textContainer.maximumNumberOfLines = 1
        
        
        guard bookAtIndexPath.isThumbnailAvailable else { return cell }
        guard let smallestThumbnail = bookAtIndexPath.smallestThumbnail else { print("bookAtIndexPath.smallestThumbnail == nil, while isThumbnailAvailable == true"); return cell }
        cell.bookTitle.text = bookAtIndexPath.title
        cell.bookCoverImage.image = smallestThumbnail
        cell.loadingIndicator.stopAnimating()
        cell.bookCoverImage.alpha = 1
        cell.backgroundColor = .clear
        
        return cell
        
    }

    
}
