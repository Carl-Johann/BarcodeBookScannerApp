//
//  PageScrollViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 04/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import Foundation
import UIKit
//
//class PageScrollViewController: UIViewController, UIScrollViewDelegate {
//
////    let scrollView = UIScrollView(frame: CGRect(x:0, y:0, width:320,height: 300))
//    let scrollView = UIScrollView()
//    var colors:[UIColor] = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow]
//    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
//    var pageControl : UIPageControl = UIPageControl(frame: CGRect(x:50,y: 300, width:200, height:50))
//    let pages = ["BookShelfVC", "BarcodeScannerVC"]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let bounds = UIScreen.main.bounds
//        let width = bounds.size.width
//        let height = bounds.size.height
//
//
//        view.addSubview(scrollView)
//        scrollView.delegate = self
//        scrollView.backgroundColor = .green
//        scrollView.isPagingEnabled = true
//        scrollView.bounces = false
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.frame = view.bounds
////        scrollView.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
////        scrollView.contentSize = CGSize(width: width, height: height)
////        scrollView.bounces = false
//        scrollView.alwaysBounceHorizontal = false
//        let aViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
//
////        addChildViewController(aViewController)
//        scrollView.addSubview(aViewController.view)
////        didMove(toParentViewController: aViewController)
//
//        //
////        let storyboard = UIStoryboard(name: "Main", bundle: nil)
////
////        let aViewController = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
////
////        let bounds = UIScreen.main.bounds
////        let width = bounds.size.width
////        let height = bounds.size.height
////
////        scrollView.contentSize = CGSize(width: 2 * width, height: height)
////
////        aViewController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
////        scrollView.addSubview(aViewController.view)
////        view.bringSubview(toFront: aViewController.view)
////        aViewController.didMove(toParentViewController: self)
//
//
////        scrollView.backgroundColor = .blue
////        // Do any additional setup after loading the view, typically from a nib.
//////        configurePageControl()
////
//
////        scrollView.isPagingEnabled = true
////        scrollView.bounces = false
////        scrollView.showsHorizontalScrollIndicator = false
////
////
////
////        view.addSubview(pageControl)
////        pageControl.numberOfPages = pages.count
////        pageControl.backgroundColor = .lightGray
////        pageControl.currentPageIndicatorTintColor = .white
////        pageControl.pageIndicatorTintColor = .darkGray
////        pageControl.currentPage = 0
////        pageControl.alpha = 0.5
////        pageControl.translatesAutoresizingMaskIntoConstraints = false
//
//
////        For the design it looks the best if the height and width value are switched
////        let pageControlWidth = pageControl.size(forNumberOfPages: pages.count).height
////        let pageControlHeight = pageControl.size(forNumberOfPages: pages.count).width
////
////        let horizontalConstraint = NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
////        let verticalConstraint = NSLayoutConstraint(item: pageControl, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -pageControlHeight)
////        let widthConstraint = NSLayoutConstraint(item: pageControl, attribute: .width, relatedBy: .equal, toItem: nil,
////                                                 attribute: .notAnAttribute, multiplier: 1, constant: pageControlWidth)
////
////        let heightConstraint = NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil,
////                                                  attribute: .notAnAttribute, multiplier: 1, constant: pageControlHeight)
////        pageControl.frame.insetBy(dx: pageControlWidth/7.5, dy: pageControlHeight/7.5)
////        pageControl.layer.cornerRadius = 4
//
//        //view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
////        let horizontalConstraint = NSLayoutConstraint(item: scrollView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
////        let verticalConstraint = NSLayoutConstraint(item: scrollView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
////        let widthConstraint = NSLayoutConstraint(item: scrollView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
////        let heightConstraint = NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
//
//
////        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
////        frame.origin.x = self.scrollView.frame.size.width * 2
////        frame.size = self.scrollView.frame.size
////
////        let lort = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
////        lort.view.frame = frame
////
////        addChildViewController(lort)
////        scrollView.addSubview(lort.view)
////        lort.didMove(toParentViewController: self)
//
//
//
//
////        self.view.addSubview(scrollView)
////        for index in 0..<Int(pages.count) {
////
////
////
////            guard let lort = storyboard?.instantiateViewController(withIdentifier: pages[index]) else { print("lorte lort virkede ikke"); return }
////            lort.view.frame = frame
////
////            lort.loadView()
////            let subView = UIView(frame: frame)
//
//            //subView.backgroundColor = colors[index]
////            addChildViewController(lort)
////            self.scrollView.addSubview(lort.view)
////
//////            print(1, lort.isViewLoaded)
////            lort.loadViewIfNeeded()
////            print(2, lort.isViewLoaded)
//        //}
//
////        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width, height: self.scrollView.frame.size.height)
//        //pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)
//
//    }
//
//    func configurePageControl() {
//        // The total number of pages that are available is based on how many available colors we have.
////        self.pageControl.numberOfPages = colors.count
//        self.pageControl.numberOfPages = pages.count
//        self.pageControl.currentPage = 0
//        self.pageControl.tintColor = UIColor.red
//        self.pageControl.pageIndicatorTintColor = UIColor.black
//        self.pageControl.currentPageIndicatorTintColor = UIColor.green
//        self.view.addSubview(pageControl)
//
//    }
//
//    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
//    func changePage(sender: AnyObject) -> () {
//        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
//        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
//    }
//
//
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
//        pageControl.currentPage = Int(pageNumber)
//    }
//
//}

