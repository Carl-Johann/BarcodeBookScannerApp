//
//  BookDetailViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 03/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit

class BookDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var contentView = UIView()
    
    var bookCoverImageView = UIImageView()
    var bookTitleLabel = UITextView()
    var bookPublisherLabel = UITextView()
    var bookPublishedDateLabel = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup of the scrollView
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .white
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 1000)
        view.addSubview(scrollView)
        
        // Setup of the contentView
        contentView.backgroundColor = .blue
        scrollView.addSubview(contentView)
        
        // Setup of the bookCoverImageView
        bookCoverImageView.backgroundColor = .red
        contentView.addSubview(bookCoverImageView)
        
        // Setup of the bookTitleLabel
        bookTitleLabel.backgroundColor = .yellow
        bookTitleLabel.text = "bookTitleLabel  adsa TUsdbfsh fihfbhfbH FBDSH KFBSd aushfaskfgasjfa fafga fajhlgfg ahjfg"
        bookTitleLabel.isUserInteractionEnabled = false
        bookTitleLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        contentView.addSubview(bookTitleLabel)
        
        // Setup of the bookPublisherLabel
        bookPublisherLabel.backgroundColor = .yellow
        bookPublisherLabel.text = "bookPublisherLabel v<jlhf oUYF Uyogfuyfguydfguyfgd oudyfgsuy ofgIFUG ipufggæu gu"
        bookPublisherLabel.isUserInteractionEnabled = false
        bookPublisherLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        contentView.addSubview(bookPublisherLabel)
        
        // Setup of the bookPublishedDateLabel
        bookPublishedDateLabel.backgroundColor = .yellow
        bookPublishedDateLabel.text = "bookPublishedDateLabel uiduhdfiu uufuiu uupf  hdfuFa d adaisudh udhuD"
        bookPublishedDateLabel.isUserInteractionEnabled = false
        bookPublishedDateLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        contentView.addSubview(bookPublishedDateLabel)
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let globalObjectWidth: CGFloat = view.frame.width * 0.9
        
        // Additional scrollView setup
        scrollView.frame = view.bounds
        
        
        // Additional contentView setup
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        
        // Additional bookCoverImageView setup
        var size = CGSize(width: globalObjectWidth, height: globalObjectWidth * 1.3)
        let topGap = (view.frame.width - size.width) / 2
        var origin = CGPoint(x: view.frame.width * 0.05, y: topGap)
        
        bookCoverImageView.frame = CGRect(origin: origin, size: size)
        bookCoverImageView.layer.cornerRadius = 3
        
        
        // Additional bookTitlelabel setup
        origin.y += (topGap * 0.8) + globalObjectWidth * 1.3
        let contentSize = bookTitleLabel.sizeThatFits(bookTitleLabel.bounds.size)
        size.height = contentSize.height
        
        bookTitleLabel.frame = CGRect(origin: origin, size: size)
        bookTitleLabel.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 5)
        bookTitleLabel.layer.cornerRadius = 3
        
        // Add the height of the bookTitleLabel to maintain even gap between views
        origin.y += bookTitleLabel.frame.height
        
        // Additional bookPublisher setup
        origin.y += topGap * 0.8
        
        let bookPublisherLabelContentSize = bookPublisherLabel.sizeThatFits(bookPublisherLabel.bounds.size)
        size.height = bookPublisherLabelContentSize.height
        
        bookPublisherLabel.frame = CGRect(origin: origin, size: size)
        bookPublisherLabel.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 5)
        bookPublisherLabel.layer.cornerRadius = 3
        
        // Add the height of the bookPublisherLabel to maintain even gap between views
        origin.y += bookPublisherLabel.frame.height
        
        // Additional bookPublishedDateLabel setup
        origin.y += topGap * 0.8
        
        let bookPublishedDateLabelContentSize = bookPublishedDateLabel.sizeThatFits(bookPublishedDateLabel.bounds.size)
        size.height = bookPublishedDateLabelContentSize.height
        
        bookPublishedDateLabel.frame = CGRect(origin: origin, size: size)
        bookPublishedDateLabel.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 5)
        bookPublishedDateLabel.layer.cornerRadius = 3
        
        // Add the height of the bookPublishedDateLabel to maintain even gap between views
        origin.y += bookPublishedDateLabel.frame.height
        
        print(1, origin.y)
        print(2, view.frame.height)
        
        
        // Update the scrollView.contentView height
        scrollView.contentSize = CGSize(width: view.frame.width, height: origin.y + topGap)
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
        
    }
    
    func setupBookCoverImageView() {
        
        let topConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 0.9, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 0.9, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: contentView,
                                                 attribute: .left, multiplier: 0.9, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: contentView,
                                                  attribute: .width, multiplier: 0.8, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: contentView,
        attribute: .width, multiplier: 1, constant: 300)
        
        contentView.addConstraints([topConstraint, rightConstraint, leftConstraint, widthConstraint, heightConstraint])
        
    }
    
    func handleBackButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
