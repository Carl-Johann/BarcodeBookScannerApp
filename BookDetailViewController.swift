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

class BookDetailViewController: UIViewController, UIScrollViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    let helveticaFont = UIFont(name: "HelveticaNeue", size: 18)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    var bookShownInDetail: Book?
    var convenienceBook: ConvenienceBook?
//    var descriptionText = ""
//    var bookTitle = ""
//    var publisherDate = ""
//    var publisher = ""
//    
    
    
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    var bookCoverImageView = UIImageView()
    var bookTitleTextView = UITextView()
    var bookPublisherTextView = UITextView()
    var bookPublishedDateTextView = UITextView()
    var bookDescriptionTextView = UITextView()
    
    var textViews : [UITextView] = []
    var isLabelAtMaxHeight = false
    
    
    lazy var fetchedResultsController = { () -> NSFetchedResultsController<Book> in
        
        let fetchRequest = NSFetchRequest<Book>(entityName: "Book")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.appDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Checks if the 'fetchedResultsController' variable returns anything. Used for debugging
        checkWithPredicate()
        
        let valuesToMakeUITextViewsOf = convenienceBook?.getValuesToMakeUITextViewsOf()
        
        print("Values in values")
        print(valuesToMakeUITextViewsOf!)
        
        for value in valuesToMakeUITextViewsOf! {
            
            
            
        }
        
        
        textViews = [
            bookTitleTextView,
            bookPublisherTextView,
            bookPublishedDateTextView,
            bookDescriptionTextView
        ]
        
        // Make sure we are notified about the right book changing
        guard (bookShownInDetail != nil) else { print("Couldn't load detailView because 'bookShownInDetail' wasn't set before the view did load")
            dismissViewController(); return
        }
        
        let predicate = NSPredicate(format: "isbn13 == %@", argumentArray: [bookShownInDetail!.isbn13])
        fetchedResultsController.fetchRequest.predicate = predicate
        
        
        // Setup of the backbutton
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismissViewController))
        navigationItem.leftBarButtonItem = backButton
        
        
        //
        //
        //        // Setup of the scrollView
        //        scrollView.frame = view.bounds
        //        scrollView.backgroundColor = .white
        //        scrollView.bounces = false
        //        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 1000)
        //        view.addSubview(scrollView)
        //
        //        // Setup of the contentView
        //        contentView.backgroundColor = .blue
        //        scrollView.addSubview(contentView)
        //
        //        // Setup of the bookCoverImageView
        //        bookCoverImageView.backgroundColor = .red
        //        contentView.addSubview(bookCoverImageView)
        //
        setupScrollAndContentView()
        setupSubviews()
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
            let imageFromNSData = UIImage(data: bookShownInDetail?.bookCoverAsData! as! Data)
            self.bookCoverImageView.image = imageFromNSData
            
        }

    }
    
    
    func setupScrollAndContentView() {
        // Setup of the scrollView
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .white
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 1000)
        view.addSubview(scrollView)
        
        // Setup of the contentView
        scrollView.addSubview(contentView)
        
        // Setup of the bookCoverImageView
        bookCoverImageView.backgroundColor = .red
        contentView.addSubview(bookCoverImageView)
        
        
    }
    
    
    func bookDescriptionReadMoreAndLessAction() {
        let minX = bookDescriptionTextView.frame.minX
        let minY = bookDescriptionTextView.frame.minY
        let point = CGPoint(x: minX, y: minY)
        
        let oldBookDescriptionTextViewHeight = bookDescriptionTextView.frame.height
        
        //
        if isLabelAtMaxHeight {
            isLabelAtMaxHeight = false
            
            bookDescriptionTextView.textContainer.maximumNumberOfLines = 2
            let bookDescriptionTextViewContentHeight = bookDescriptionTextView.sizeThatFits(bookDescriptionTextView.bounds.size).height
            let size = CGSize(width: bookDescriptionTextView.frame.width, height: bookDescriptionTextViewContentHeight)
            bookDescriptionTextView.frame = CGRect(origin: point, size: size)
            
            scrollView.contentSize = CGSize(width: view.frame.width, height: scrollView.contentSize.height - oldBookDescriptionTextViewHeight + bookDescriptionTextViewContentHeight)
            contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
        }
        else {
            isLabelAtMaxHeight = true
            
            bookDescriptionTextView.textContainer.maximumNumberOfLines = 0
            let bookDescriptionTextViewContentHeight = bookDescriptionTextView.sizeThatFits(bookDescriptionTextView.bounds.size).height
            let size = CGSize(width: bookDescriptionTextView.frame.width, height: bookDescriptionTextViewContentHeight)
            bookDescriptionTextView.frame = CGRect(origin: point, size: size)
            
            scrollView.contentSize = CGSize(width: view.frame.width, height: scrollView.contentSize.height + bookDescriptionTextViewContentHeight - oldBookDescriptionTextViewHeight)
            contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
            
        }
    }
    
    func checkWithPredicate() {
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
        fetchRequest.sortDescriptors = [ ]
        let predicatee = NSPredicate(format: "isbn13 == %@", argumentArray: [bookShownInDetail!.isbn13])
        fetchRequest.predicate = predicatee
        
        let context = self.appDelegate.stack.context
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
        
        // Makes an annotation from all fetched objects
        print(fetchedResultsController.fetchedObjects!)
        
        print()
        print("did download fetchedObjects")
        print()

    
    }
    
    //    func layOutViews() {
    //        for textView in textViews {
    //            // Setup of the textView
    //            textView.backgroundColor = .yellow
    //            textView.textContainer.maximumNumberOfLines = 0
    //            textView.text = "textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView"
    //            textView.isUserInteractionEnabled = false
    //            textView.font = helveticaFont
    //            contentView.addSubview(textView)
    //        }
    //
    //        // Do any special setup
    //        let bookDescriptionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bookDescriptionReadMoreAndLessAction))
    //        bookDescriptionTextView.addGestureRecognizer(bookDescriptionTapGestureRecognizer)
    //        bookDescriptionTextView.textContainer.maximumNumberOfLines = 2
    //        bookDescriptionTextView.isScrollEnabled = false
    //        bookDescriptionTextView.isSelectable = false
    //        bookDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
    //        bookDescriptionTextView.isUserInteractionEnabled = true
    //        bookDescriptionTextView.text = "textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView"
    //
    //    }
    
    
    
    
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //
    //        // Constant values based on device screen size
    //        let globalObjectWidth: CGFloat = view.frame.width * 0.9
    //        let textViewPadding = UIEdgeInsetsMake(5, 5, 5, 5)
    //        let bookCoverImageViewHeight = globalObjectWidth * 1.3
    //
    //
    //        // Additional bookCoverImageView setup
    //        var size = CGSize(width: globalObjectWidth, height: bookCoverImageViewHeight)
    //        let topGap = (view.frame.width - size.width) / 2
    //        var origin = CGPoint(x: view.frame.width * 0.05, y: topGap)
    //
    //        bookCoverImageView.frame = CGRect(origin: origin, size: size)
    //        bookCoverImageView.layer.cornerRadius = 3
    //        origin.y += bookCoverImageViewHeight
    //
    //
    //        for textView in textViews {
    //            // Sets the textView at the right height
    //            origin.y += topGap * 0.8
    //
    //            // Calculates the height of the textView by making a view the fits inside of itself
    //            let textViewContentSize = textView.sizeThatFits(textView.bounds.size)
    //            size.height = textViewContentSize.height
    //
    //            // Sets up the different parameters
    //            textView.frame = CGRect(origin: origin, size: size)
    //            textView.textContainerInset = textViewPadding
    //            textView.layer.cornerRadius = 3
    //
    //            // Adds the height of the textView to the shared value 'origin.y'
    //            // so the next textView starts at the propper y value
    //            origin.y += textView.frame.height
    //        }
    //
    //        // After setting up all the textView sets up the 'contentSize' and 'contentView'
    //        // so the whole viewController's length is dynamic based on lengths of the different textViews
    //        scrollView.contentSize = CGSize(width: view.frame.width, height: origin.y + topGap)
    //        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
    //    }
    
    
    
    
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
}
