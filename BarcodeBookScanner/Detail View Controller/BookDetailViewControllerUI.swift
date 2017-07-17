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
                let biggestThumbnail = convenienceBook!.getBiggestThumbnail()
                
                
                if let largestThumbnail = convenienceBook?.largestThumbnail {
                    
                    // Gives the image the right size based on the 'globalObjectWidth'
                    let resizedCoverImage = resizeImage(image: largestThumbnail, newWidth: globalObjectWidth)
                    bookCoverImageView.image = resizedCoverImage
                    bookCoverImageView.frame = CGRect(origin: origin, size: (resizedCoverImage?.size)!)
                } else if !(biggestThumbnail.isEmpty) {
                    
                    let url = URL(string: biggestThumbnail)
                    let data = try? Data(contentsOf: url!)
                    let imageFromURL = UIImage(data: data!)
                    
                    // Gives the image the right size based on the 'globalObjectWidth'
                    let resizedCoverImage = resizeImage(image: imageFromURL!, newWidth: globalObjectWidth)
                    bookCoverImageView.image = resizedCoverImage
                    bookCoverImageView.frame = CGRect(origin: origin, size: (resizedCoverImage?.size)!)
                    
                }
                
                
                // Makes it look right,
                bookCoverImageView.layer.cornerRadius = 3
                bookCoverImageView.layer.masksToBounds = true
                // and makes the next view sit in the right spot
                bookCoverImageViewHeight = bookCoverImageView.frame.height
                origin.y += bookCoverImageViewHeight
                
                // Download resten af den scannede bog, og vis den. KILL IT!!!!!
                
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
                
            } else if let addToBookshelf = subView as? UICollectionView {                
                origin.y += topGap * 0.55
                
                size.height = addToBookshelf.collectionViewLayout.collectionViewContentSize.height
                addToBookshelf.frame = CGRect(origin: origin, size: size)
                addToBookshelf.layer.cornerRadius = 3
                
                // We need to reload the bookshelf, else the cells
                // aren't adjusted to the width of the addToBookshelf.frame.width
                addToBookshelf.reloadData()
                
                origin.y += addToBookshelf.frame.height
            }
            
        }
        
        
        // After setting up all the textView sets up the 'contentSize' and 'contentView'
        // so the whole viewController's length is dynamic based on lengths of the different textViews
        scrollView.contentSize = CGSize(width: view.frame.width, height: origin.y + topGap)
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height + 5)
    }
    
    
    
    func imageFromURL(urlString: String) {
        // The contents of the url are retrieved on a concurrent que to avoid errors with 'backthreading'
        let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
        concurrentQueue.sync {
            
            let url = URL(string: urlString)
            let data = try? Data(contentsOf: url!)
            let imageFromURL = UIImage(data: data!)
            
            convenienceBook!.isThumbnailAvailable = true
            convenienceBook!.largestThumbnail = imageFromURL
            
            for subview in contentView.subviews {
                if let bookCoverImageView = subview as? UIImageView {
                    bookCoverImageView.image = imageFromURL
                }
            }
        }
    }
}
