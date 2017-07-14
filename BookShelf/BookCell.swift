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
    @IBOutlet weak var bookTitle: UITextView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    var associatedConvenienceBook: ConvenienceBook?
}
