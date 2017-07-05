//
//  ScrollPageViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 04/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit

class PageScrollViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let pageControl = UIPageControl()
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    let pages = ["BookShelfVC", "BarcodeScannerVC"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //configurePageControl()
        
        
        scrollView.bounces = false
        scrollView.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        
        
        //Initialize using Unique ID for the View
        guard let BarcodeScannerVC = self.storyboard?.instantiateViewController(withIdentifier: "BarcodeScannerVC") as? BarcodeScannerViewController! else { print("Fufkcufkcufkcufkcufkcufkcufkc"); return }
        //Add initialized view to main view and its scroll view also set bounds
        self.addChildViewController(BarcodeScannerVC)
        self.scrollView.addSubview(BarcodeScannerVC.view)
        BarcodeScannerVC.didMove(toParentViewController: self)
        BarcodeScannerVC.view.frame = scrollView.bounds
        
        //Create frame for the view and define its urigin point with respect to View 1
        var BarcodeScannerVCFrame: CGRect = BarcodeScannerVC.view.frame
        BarcodeScannerVCFrame.origin.x = self.view.frame.width
        BarcodeScannerVC.view.frame = BarcodeScannerVCFrame
        
        
        guard let BookShelfVC = self.storyboard?.instantiateViewController(withIdentifier: "BookShelfVC") as? BookShelf! else { print("lortlortlortlortlortlortlortlortlortlort"); return }
        //Add initialized view to main view and its scroll view and also set bounds
        self.addChildViewController(BookShelfVC)
        self.scrollView.addSubview(BookShelfVC.view)
        BookShelfVC.didMove(toParentViewController: self)
        BookShelfVC.view.frame = scrollView.bounds
        //Create frame for the view and define its urigin point with respect to View 1 - We dont need it here
        
        
        self.scrollView.contentSize = CGSize(width: (self.view.frame.width) * 2, height: (self.view.frame.height))
        
        //The offset values are for telling where the scroll view sees its x and y point as origin
        //try setting the value to 2, and 3 to feel the difference----this value here
        //
        self.scrollView.contentOffset = CGPoint(x: (self.view.frame.width), y: (self.view.frame.height))
        
        
//        
    }
    
    func configurePageControl() {
        view.addSubview(pageControl)
        pageControl.numberOfPages = pages.count
        pageControl.backgroundColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPage = 0
        pageControl.alpha = 0.5
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        
//        For the design it looks the best if the height and width value are switched
        let pageControlWidth = pageControl.size(forNumberOfPages: pages.count).height
        let pageControlHeight = pageControl.size(forNumberOfPages: pages.count).width
        let horizontalConstraint = NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: pageControl, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -pageControlHeight)
        let widthConstraint = NSLayoutConstraint(item: pageControl, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1, constant: pageControlWidth)
        
        let heightConstraint = NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1, constant: pageControlHeight)
        pageControl.frame.insetBy(dx: pageControlWidth/7.5, dy: pageControlHeight/7.5)
        pageControl.layer.cornerRadius = 4
        
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}
