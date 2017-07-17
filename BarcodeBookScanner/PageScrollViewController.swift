//
//  PageScrollViewController.swift
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
        
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        
        let BarcodeScannerVC = self.storyboard?.instantiateViewController(withIdentifier: "BarcodeScannerVC") as! BarcodeScannerViewController!
        
        self.addChildViewController(BarcodeScannerVC!)
        self.scrollView.addSubview(BarcodeScannerVC!.view)
        BarcodeScannerVC!.didMove(toParentViewController: self)
        BarcodeScannerVC!.view.frame = scrollView.bounds
        
        
        var BarcodeScannerVCFrame: CGRect = BarcodeScannerVC!.view.frame
        BarcodeScannerVCFrame.origin.x = self.view.frame.width
        BarcodeScannerVC!.view.frame = BarcodeScannerVCFrame
        
        
        let BookShelfVC = self.storyboard?.instantiateViewController(withIdentifier: "BookShelfVC") as! BookShelfCV!
        
        self.addChildViewController(BookShelfVC!)
        self.scrollView.addSubview(BookShelfVC!.view)
        BookShelfVC!.didMove(toParentViewController: self)
        BookShelfVC!.view.frame = scrollView.bounds
        
        
        self.scrollView.contentSize = CGSize(width: (self.view.frame.width) * 2, height: (self.view.frame.height))
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
        
        configurePageControl()
        //
    }
    
    
    
    
    func configurePageControl() {
        
        pageControl.numberOfPages = pages.count
        
        pageControl.currentPageIndicatorTintColor = .darkGray
        pageControl.backgroundColor = .clear
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPage = 0
        pageControl.alpha = 0.7
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        //      For the design, it looks best if the height and width value are switched
        let pageControlWidth = pageControl.size(forNumberOfPages: pages.count).height
        let pageControlHeight = pageControl.size(forNumberOfPages: pages.count).width
        
        let horizontalConstraint = NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: pageControl, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -pageControlHeight)
        let widthConstraint = NSLayoutConstraint(item: pageControl, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1, constant: pageControlWidth)
        
        let heightConstraint = NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1, constant: pageControlHeight)
        
        
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}

