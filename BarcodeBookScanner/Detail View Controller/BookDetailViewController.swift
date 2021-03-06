//
//  BookDetailViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 03/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit
import Cosmos


class BookDetailViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    let cellID = "cellID"
    var titles: [String] = []
    
    let font = UIFont(name: "TimesNewRomanPSMT", size: 21)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isLabelAtMaxHeight = false
    
    var convenienceBook: ConvenienceBook?
    
    var postButton: UIBarButtonItem!
    var addToBookshelf: UICollectionView!
    var scrollView = UIScrollView()
    var contentView = UIView()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup of the backbutton
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissViewController))
        navigationItem.leftBarButtonItem = doneButton
        self.title = "Detail Page"
        
        // Setup of the add button
        postButton = UIBarButtonItem(image: UIImage(named: "mediumAddToBookshelfIcon"), style: .plain , target: self, action: #selector(postSelectedBookshelfOptions))
        
        guard (convenienceBook != nil) else { print("ConveninceBook is nil"); errorOccuredErrorAlert(); return }
        
        // If there's a thumbnail available we setup the 'bookCoverImageView'
        if convenienceBook!.isThumbnailAvailable { setupBookCoverImageView() }
        
        // Make UIViews from convenienceBook
        makeUIViewsFromConvenienceBook()
        
        // Setup of the addToBookshelf collectionView
        setupAddToBookshelfCV()
        
        // Setup of the scrollView and ContentView
        setupScrollAndContentView()        
        
    }
    
    
    func postSelectedBookshelfOptions() {
        let preDeleteRowCount = numberOfRowsInAddToCV()
        
        // We need to order the selected items to avoid 'index our of range'
        let selectedItems = addToBookshelf.indexPathsForSelectedItems!.sorted { (item1, item2) -> Bool in
            return item1 > item2
        }
        
        for indexPath in selectedItems {
            addToBookshelf.performBatchUpdates({
                self.addToBookshelf.deleteItems(at: [indexPath])
                self.titles.remove(at: indexPath.item)
            })
            GoogleBooksClient.sharedInstance.postToBookshelf(BookshelfID: indexPath[1], bookID: convenienceBook!.bookID, add: true)
        }
        
        
        let postDeleteRowCount = numberOfRowsInAddToCV()
        if preDeleteRowCount != postDeleteRowCount {
            
            let postDeleteCVHeight = itemSize().height * preDeleteRowCount
            let currentCVHeight = itemSize().height * postDeleteRowCount
            
            let heightDifference = postDeleteCVHeight - currentCVHeight
            
            
            let maxScrollDistance = contentView.frame.height - view.frame.height - 5
            // If the 'yValueToScrollTo' - wanted scroll distance - is larger than the allowed macScrollDistance,
            // we scroll to the default, safe value 'maxScrollDistance'
            
            // We add the navBar height and subtract the interitemspacing 
            var yValueToScrollTo = scrollView.bounds.origin.y - heightDifference + 64 - 3
            yValueToScrollTo = min(yValueToScrollTo, maxScrollDistance)
            let pointToScrollTo = CGPoint(x: 0, y: scrollView.bounds.origin.y - heightDifference)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.scrollView.setContentOffset(pointToScrollTo, animated: false)
            }, completion: { (true) in
                self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollView.contentSize.height - heightDifference)
                self.contentView.frame = CGRect(x: 0, y: 0, width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height * 1.01)
            })
        }
    }
    
    func numberOfRowsInAddToCV() -> CGFloat {
        let titles = CGFloat(self.titles.count)
        let rows = (titles / 4).rounded(.up)

        return rows
    }
    
    
    func itemSize() -> CGSize {
        let globalObjectWidth: CGFloat = (view.frame.width * 0.9)
        let numberOfItemsPerRow: CGFloat = 4.0
        let itemSize = (globalObjectWidth/numberOfItemsPerRow) - 3
        
        return CGSize(width: itemSize, height: itemSize)
    }
        
    
    func bookDescriptionReadMoreAndLessAction() {
        
        for subView in contentView.subviews {
            if subView.tag == 1 {
                let bookDescriptionTextView = subView as! UITextView
                
                
                let minX = bookDescriptionTextView.frame.minX
                let minY = bookDescriptionTextView.frame.minY
                let point = CGPoint(x: minX, y: minY)
                
                let oldBookDescriptionTextViewHeight = bookDescriptionTextView.frame.height
                let bookDescriptionOriginY = bookDescriptionTextView.frame.origin.y
                
                var viewsToMove: [UIView] = []
                
                // Locates the views with a larger y value 'bookDescriptionTextView', beacuse that view will be under the
                // 'bookDescriptionTextView' in the view, and should be moved accordingly to 'bookDescriptionTextView'
                for view in contentView.subviews {
                    if view.frame.origin.y > bookDescriptionOriginY { viewsToMove.append(view) }
                }
                
                //
                if isLabelAtMaxHeight {
                    isLabelAtMaxHeight = false
                    
                    bookDescriptionTextView.textContainer.maximumNumberOfLines = 2
                    let bookDescriptionTextViewContent = bookDescriptionTextView.sizeThatFits(bookDescriptionTextView.bounds.size)
                    let size = CGSize(width: bookDescriptionTextView.frame.width, height: bookDescriptionTextViewContent.height)
                    bookDescriptionTextView.frame = CGRect(origin: point, size: size)
                    
                    
                    // Subtracts the correct y value to all views under the 'bookDescriptionTextView',
                    // which causes all the views to move up as the 'bookDescriptionTextView' is collapsed
                    let yValueToSubtractFromView = oldBookDescriptionTextViewHeight - bookDescriptionTextViewContent.height
                    
                    for view in viewsToMove {
                        var origin = view.frame.origin
                        origin.y -= yValueToSubtractFromView
                        view.frame = CGRect(origin: origin, size: view.bounds.size)
                    }
                    
                    
                    
                    scrollView.contentSize = CGSize(width: view.frame.width, height: scrollView.contentSize.height - oldBookDescriptionTextViewHeight + bookDescriptionTextViewContent.height)
                    
                    contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
                }
                else {
                    isLabelAtMaxHeight = true
                    
                    bookDescriptionTextView.textContainer.maximumNumberOfLines = 0
                    let bookDescriptionTextViewContentHeight = bookDescriptionTextView.sizeThatFits(bookDescriptionTextView.bounds.size).height
                    let size = CGSize(width: bookDescriptionTextView.frame.width, height: bookDescriptionTextViewContentHeight)
                    bookDescriptionTextView.frame = CGRect(origin: point, size: size)
                    
                    
                    // Adds the correct y value to all views under the 'bookDescriptionTextView',
                    // which causes all the views to move down as the 'bookDescriptionTextView' is extended
                    let yValueToAddToView = bookDescriptionTextViewContentHeight - oldBookDescriptionTextViewHeight
                    
                    for view in viewsToMove {
                        var origin = view.frame.origin
                        origin.y += yValueToAddToView
                        view.frame = CGRect(origin: origin, size: view.bounds.size)
                    }
                    
                    
                    scrollView.contentSize = CGSize(width: view.frame.width, height: scrollView.contentSize.height + bookDescriptionTextViewContentHeight - oldBookDescriptionTextViewHeight)
                    contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
                    
                    // The desired Y position for the 'bookDescriptionTextView'
                    var yValueToScrollTo = bookDescriptionOriginY * 0.7
                    
                    // If the contentView past the 'bookDescriptionTextView' is not tall enough,
                    // we set a 'maxScrollDistance' value to ensure we never scrool onto a big white spot under the 'contentView'
                    let maxScrollDistance = contentView.frame.height - view.frame.height - 5
                    
                    // If the 'yValueToScrollTo' - wanted scroll distance - is larger than the allowed macScrollDistance,
                    // we scroll to the default, safe value 'maxScrollDistance'
                    yValueToScrollTo = min(yValueToScrollTo, maxScrollDistance)
                    let pointToScrollTo = CGPoint(x: 0, y: yValueToScrollTo)
                    
                    scrollView.setContentOffset(pointToScrollTo, animated: true)
                }
            }
        }
    }
    
    
    
    func errorOccuredErrorAlert() {
        print("errorOccuredErrorAlert called")
        let alert = UIAlertController(title: "Error", message: "An error occured. Try agian", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismissViewController()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
}
