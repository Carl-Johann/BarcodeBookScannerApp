//
//  BookDetailViewSetups.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 13/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit


extension BookDetailViewController {

    
    func makeUIViewsFromConvenienceBook() {
        let valuesToMakeUIViewsOf = convenienceBook!.getValuesToMakeUIViewsOf()
        
        for value in valuesToMakeUIViewsOf {
            switch value.key {
                
            case "Rating":
                setupRatingCosmosView(rating: Double(value.value)!)
                
            case "Description":
                setupDescriptionTextView(key: value.key, value: value.value)
                
            default:
                setupTextView(key: value.key, value: value.value)
                
            }
        }
    }
    
    
    
    func setupScrollAndContentView() {
        // Setup of the scrollView
        scrollView.frame = view.bounds
//        scrollView.backgroundColor = .darkGray
        scrollView.backgroundColor = .white
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 1000)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
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
        
        bookDescriptionTextView.layer.backgroundColor = UIColor.lightGray.cgColor
        bookDescriptionTextView.layer.borderWidth = 1.5
        
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
        ratingView.settings.emptyBorderColor = .black
        
        ratingView.settings.fillMode = .precise
        ratingView.rating = rating
    }
    
    
    
    func setupTextView(key: String, value: String) {
        
        let textView = UITextView()
        textView.layer.backgroundColor = UIColor.lightGray.cgColor        
        textView.layer.borderWidth = 1.5
        textView.textContainer.maximumNumberOfLines = 0
        textView.text = "\(key): \(value)"
        textView.isUserInteractionEnabled = false
        textView.font = font
        contentView.addSubview(textView)
    }
    
    
    
    func setupBookCoverImageView() {
        
        let bookCoverImageView = UIImageView()
        contentView.addSubview(bookCoverImageView)
    }
    
    
    
    func setupAddToBookshelfCV() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize()
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        addToBookshelf = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        addToBookshelf.dataSource = self
        addToBookshelf.delegate = self
        addToBookshelf.allowsMultipleSelection = true
        
        addToBookshelf.isPagingEnabled = false
        addToBookshelf.isScrollEnabled = false
        
        addToBookshelf.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
//        addToBookshelf.backgroundColor = .darkGray
        addToBookshelf.backgroundColor = .white
        contentView.addSubview(addToBookshelf)
        
    }

    

}
