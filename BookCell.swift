//
//  BookCollectionViewCell.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 27/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//
import Foundation
import UIKit

class BookCell: UICollectionViewCell {
    
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    
    
    /*let coverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.blue
        return imageView
    }()
    
    let bookTitle: UILabel = {
        let title = UILabel()
        title.backgroundColor = UIColor.black
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addViews()
    }
    
    
    
    func addViews() {
        backgroundColor = UIColor.cyan
//        heightAnchor = 300.isActive = true
//        widthAnchor = 100.isActive = true
        
        
        addSubview(coverImage)
        addSubview(bookTitle)
    
        coverImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        coverImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        coverImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //coverImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 50).isActive = true
        //coverImage.heightAnchor
        
        //bookTitle.topAnchor.constraint(equalTo: topAnchor, constraints: ).isActive = true
        bookTitle.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        bookTitle.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        bookTitle.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
}
