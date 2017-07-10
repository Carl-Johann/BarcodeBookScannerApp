//
//  BookDetailViewControllerUI.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 06/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

extension BookDetailViewController {
    
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Constant values based on device screen size
        let globalObjectWidth: CGFloat = view.frame.width * 0.9
        let textViewPadding = UIEdgeInsetsMake(5, 5, 5, 5)
        var bookCoverImageViewHeight: CGFloat = 0.0
        
        
        // Additional bookCoverImageView setup
        var size = CGSize(width: globalObjectWidth, height: bookCoverImageViewHeight)
        let topGap = (view.frame.width - size.width) / 2
        var origin = CGPoint(x: view.frame.width * 0.05, y: topGap)
        
        
        
        
        
        for subView in contentView.subviews {
            if let bookCoverImageView = subView as? UIImageView {
                
                if let bookCoverImage = bookShownInDetail!.bookCoverAsData {
                    // Gives the image the right size based in the 'globalObjectWidth'
                    let coverImage = UIImage(data: bookCoverImage as! Data)
                    let resizedCoverImage = resizeImage(image: coverImage!, newWidth: globalObjectWidth)
                    bookCoverImageView.image = resizedCoverImage
                    
                    bookCoverImageView.frame = CGRect(origin: origin, size: (resizedCoverImage?.size)!)
                    // Makes it look right,
                    bookCoverImageView.layer.cornerRadius = 3
                    bookCoverImageView.layer.masksToBounds = true
                    // and makes the next view sit in the right spot
                    bookCoverImageViewHeight = bookCoverImageView.frame.height
                    origin.y += bookCoverImageViewHeight
                    
                } else if convenienceBook!.isThumbnailAvailable {
                    let biggestThumbnailURL = convenienceBook!.getBiggestThumbnail()
                    // Updating the Book will in return notify the 'fetchedResultsController' which will update the view
                    imageFromURL(book: bookShownInDetail!, urlString: biggestThumbnailURL)
                    
                    
                }
            } else if let textField = subView as? UITextView {
                
                // Sets the textView at the right height
                origin.y += topGap * 0.55
                
                // Calculates the height of the textView by making a view the fits inside of itself
                let textViewContentSize = textField.sizeThatFits(textField.bounds.size)
                size.height = textViewContentSize.height
                
                // Sets up the different parameters
                textField.frame = CGRect(origin: origin, size: size)
                textField.textContainerInset = textViewPadding
                
                textField.layer.cornerRadius = 3
                
                // Adds the height of the textView to the shared value 'origin.y'
                // so the next textView starts at the propper y value
                origin.y += textField.frame.height
                
                
            } else if let ratingView = subView as? CosmosView {
                
                origin.y += topGap * 0.55
                
                let starMargin = size.width / 5
                let starSize = size.width / 5
                ratingView.settings.emptyBorderWidth = Double(starSize / 10)
                ratingView.starSize = (Double(size.width - starMargin)) / 5.0
                
                
                ratingView.starSize = Double(starSize) - ratingView.starMargin
                let ratingsViewContentSize = ratingView.sizeThatFits(ratingView.bounds.size)
                size.height = ratingsViewContentSize.height
                
                
                ratingView.frame = CGRect(origin: origin, size: size)
                ratingView.layer.cornerRadius = 3
                origin.y += ratingView.frame.height
                
            }
        }
        
        
        // After setting up all the textView sets up the 'contentSize' and 'contentView'
        // so the whole viewController's length is dynamic based on lengths of the different textViews
        scrollView.contentSize = CGSize(width: view.frame.width, height: origin.y + topGap)
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
    }
    
    func setupScrollAndContentView() {
        // Setup of the scrollView
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .darkGray
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 1000)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
    }
    
    
    func imageFromURL(book: Book, urlString: String) {
        print("imageFromURL was called")
        // The contents of the url are retrieved on a concurrent que to avoid errors with 'backthreading'
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.sync {
            
            let url = URL(string: urlString)
            let data = try? Data(contentsOf: url!)
            let imageFromURL = UIImage(data: data!)
            
            book.bookCoverAsData = UIImagePNGRepresentation(imageFromURL!) as NSData?
            
            do { try self.appDelegate.stack.saveContext() }
            catch { print("ERROR: \(error)") }
            
        }
    }
    
    
    
    func makeUIViewsFromConvenienceBook() {
        let valuesToMakeUIViewsOf = convenienceBook!.getValuesToMakeUIViewsOf()
        
        for value in valuesToMakeUIViewsOf {
            switch value.key {
                
            case "Rating":
                setupRatingCosmosView(rating: Double(value.value)!)
                
            case "Page Count":
                //                setupPageCountTextView(key: value.key, value: value.value)
                setupTextView(key: value.key, value: value.value)
                
            case "Description":
                setupDescriptionTextView(key: value.key, value: value.value)
                
            default:
                setupTextView(key: value.key, value: value.value)
                
            }
        }
    }
    
}
