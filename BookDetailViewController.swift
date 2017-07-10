//
//  BookDetailViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 03/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Cosmos

class BookDetailViewController: UIViewController, UIScrollViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    let helveticaFont = UIFont(name: "IowanOldStyle-Roman", size: 21)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isLabelAtMaxHeight = false
    
    var bookShownInDetail: Book?
    var convenienceBook: ConvenienceBook?
    
    var scrollView = UIScrollView()
    var contentView = UIView()
//    var bookCoverImageView = UIImageView()
    
    
    lazy var fetchedResultsController = { () -> NSFetchedResultsController<Book> in
        
        let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup of the backbutton
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissViewController))
        navigationItem.leftBarButtonItem = doneButton
        self.title = "Detail Page"
        
        // Checks if the 'fetchedResultsController' variable returns anything. Used for debugging
        //checkWithPredicate()
        guard (convenienceBook != nil) else { print("ConveninceBook is nil"); errorOccuredErrorAlert(); return }
        guard (bookShownInDetail != nil) else { print("bookShownInDetail is nil"); errorOccuredErrorAlert(); return }
        
        // If there's a thumbnail available we setup the 'bookCoverImageView'
        if convenienceBook!.isThumbnailAvailable || bookShownInDetail!.bookCoverAsData != nil {
            print("Thumbnail is available")
            setupBookCoverImageView()
        }
        //
        makeUIViewsFromConvenienceBook()
        
        // Make sure we are notified about the right book changing
        guard (bookShownInDetail != nil) else { print("Couldn't load detailView because 'bookShownInDetail' wasn't set before the view did load")
            errorOccuredErrorAlert(); return
        }
        
        let predicate = NSPredicate(format: "isbn13 == %@", argumentArray: [bookShownInDetail!.isbn13])
        fetchedResultsController.fetchRequest.predicate = predicate
        
        setupScrollAndContentView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            print("deleted an object")
        case .insert:
            print("inserted an object")
        case .move:
            print("moved an object")
        case .update:
            print("updated an object")
            
            for subview in contentView.subviews {
                if let bookCoverImageView = subview as? UIImageView {
                    let imageFromNSData = UIImage(data: bookShownInDetail!.bookCoverAsData! as! Data)
                    bookCoverImageView.image = imageFromNSData
                }
            }
            
        }
    }
    
    
    func setupDescriptionTextView(key: String, value: String) {
        
        // Do any special setup
        let bookDescriptionTextView = UITextView()
        // We give the 'bookDescriptionTextView' a tag so we can locate it in our 'bookDescriptionReadMoreAndLessAction' method
        bookDescriptionTextView.tag = 1
        let bookDescriptionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bookDescriptionReadMoreAndLessAction))
        bookDescriptionTextView.addGestureRecognizer(bookDescriptionTapGestureRecognizer)
        bookDescriptionTextView.textContainer.maximumNumberOfLines = 2
        bookDescriptionTextView.isScrollEnabled = false
        bookDescriptionTextView.isSelectable = false
        bookDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        bookDescriptionTextView.isUserInteractionEnabled = true
        bookDescriptionTextView.text = "\(key): \(value)"
    }
    
    func setupRatingCosmosView(rating: Double) {
        
        // RatingView
        let ratingView = CosmosView()
        ratingView.backgroundColor = .clear
        ratingView.updateOnTouch = false
        
        ratingView.settings.filledColor = .yellow
        ratingView.settings.filledBorderColor = .yellow
        ratingView.settings.emptyColor = .clear
        ratingView.settings.emptyBorderColor = .gray
        
        ratingView.settings.fillMode = .precise
        ratingView.rating = rating
    }
    
    func setupTextView(key: String, value: String) {
        
        let textView = UITextView()
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.backgroundColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.5
        textView.textContainer.maximumNumberOfLines = 0
        textView.text = "\(key): \(value)"
        textView.isUserInteractionEnabled = false
        textView.font = helveticaFont
        contentView.addSubview(textView)
    }
    
    func setupBookCoverImageView() {
        
        let bookCoverImageView = UIImageView()
        contentView.addSubview(bookCoverImageView)
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
                    
                    
                    //          Subtracts the correct y value to all views under the 'bookDescriptionTextView',
                    //          which causes all the views to move up as the 'bookDescriptionTextView' is collapsed
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
