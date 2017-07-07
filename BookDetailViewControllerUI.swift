//
//  BookDetailViewControllerUI.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 06/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit


extension BookDetailViewController {


    func setupSubviews(textDescription: String, text: String) {
        for textView in textViews {
            
            // Setup of the textView
            textView.backgroundColor = .yellow
            textView.textContainer.maximumNumberOfLines = 0
//            textView.text = "textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView"
            textView.text = "\(textDescription): \(text)"
            textView.isUserInteractionEnabled = false
            textView.font = helveticaFont
            contentView.addSubview(textView)
        }
        
        // Do any special setup
        let bookDescriptionTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bookDescriptionReadMoreAndLessAction))
        bookDescriptionTextView.addGestureRecognizer(bookDescriptionTapGestureRecognizer)
        bookDescriptionTextView.textContainer.maximumNumberOfLines = 2
        bookDescriptionTextView.isScrollEnabled = false
        bookDescriptionTextView.isSelectable = false
        bookDescriptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        bookDescriptionTextView.isUserInteractionEnabled = true
        bookDescriptionTextView.text = "textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView textView xtViewt extVie wtextViewtex tViewtextV iewtex tViewtextVi ewtex  ewtextVi ewtextView ewtextView ewtextView ewtextView"
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Constant values based on device screen size
        let globalObjectWidth: CGFloat = view.frame.width * 0.9
        let textViewPadding = UIEdgeInsetsMake(5, 5, 5, 5)
        let bookCoverImageViewHeight = globalObjectWidth * 1.3
        
        
        // Additional bookCoverImageView setup
        var size = CGSize(width: globalObjectWidth, height: bookCoverImageViewHeight)
        let topGap = (view.frame.width - size.width) / 2
        var origin = CGPoint(x: view.frame.width * 0.05, y: topGap)
        
        // Places the view in the right spot,
        bookCoverImageView.frame = CGRect(origin: origin, size: size)
        // makes it look right,
        bookCoverImageView.layer.cornerRadius = 3
        // and makes the next view sit in the right spot
        origin.y += bookCoverImageViewHeight
        
        
        
        for textView in textViews {
            // Sets the textView at the right height
            origin.y += topGap * 0.8
            
            // Calculates the height of the textView by making a view the fits inside of itself
            let textViewContentSize = textView.sizeThatFits(textView.bounds.size)
            size.height = textViewContentSize.height
            
            // Sets up the different parameters
            textView.frame = CGRect(origin: origin, size: size)
            textView.textContainerInset = textViewPadding
            textView.layer.cornerRadius = 3
            
            // Adds the height of the textView to the shared value 'origin.y'
            // so the next textView starts at the propper y value
            origin.y += textView.frame.height
        }
        
        
        // After setting up all the textView sets up the 'contentSize' and 'contentView'
        // so the whole viewController's length is dynamic based on lengths of the different textViews
        scrollView.contentSize = CGSize(width: view.frame.width, height: origin.y + topGap)
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
    }

    
    

}
