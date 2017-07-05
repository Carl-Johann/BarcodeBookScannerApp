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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup of the backbutton
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleBackButtonAction))
        navigationItem.leftBarButtonItem = backButton
        
        // Setup of the scrollView
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.black
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.frame = view.bounds
        // Disables horizontal scrolling
        scrollView.contentSize.width = view.frame.width
        //
        scrollView.contentSize.height = 2000
        
        // Setup of the contentView
        scrollView.addSubview(contentView)
        
        
        
        let horizontalConstraint = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)

        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])

    }
    
    
    
    
    func handleBackButtonAction() {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
}
