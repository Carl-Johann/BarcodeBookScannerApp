//
//  AddToShelfCollectionView.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 13/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit


extension BookDetailViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        selectedCell?.alpha = 0.5
        self.checkAndUpdateView(selectedCell!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        selectedCell?.alpha = 1
        self.checkAndUpdateView(selectedCell!)
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        cell.layer.borderWidth = 1.5
        cell.layer.cornerRadius = 3
        cell.layer.borderColor = UIColor.black.cgColor
        
        let textView = UITextView()
        textView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: itemSize())
        textView.text = titles[indexPath[1]]
        textView.textContainer.maximumNumberOfLines = 0
        textView.textAlignment = .center
        textView.isUserInteractionEnabled = false
        textView.textContainer.lineBreakMode = .byClipping
        textView.backgroundColor = .lightGray
        textView.layer.cornerRadius = 3

        let deadSpace = textView.bounds.size.height - textView.contentSize.height
        let inset = max(0, deadSpace/2.0)
        textView.contentInset = UIEdgeInsetsMake(inset, textView.contentInset.left, inset, textView.contentInset.right)
        
        cell.addSubview(textView)

        return cell
    }
    
    
    func checkAndUpdateView(_ selectedCell: UICollectionViewCell) {
        
        if addToBookshelf.indexPathsForSelectedItems?.count != 0 {
            navigationItem.rightBarButtonItems = [postButton]
            
        } else {
            if addToBookshelf.indexPathsForSelectedItems?.count == 0 {
                navigationItem.rightBarButtonItems = []
                
            }
        }
    }

    
}
