//
//  PageViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 02/07/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//



import Foundation
import UIKit

class PageViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate {
    fileprivate var currentIndex = 0
    fileprivate var lastPosition: CGFloat = 0
    
    let pages = ["BookShelfVC", "BarcodeScannerVC"]
    var pageControl = UIPageControl()
    let scrollView = UIScrollView()
    var pageView = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.delegate = self
        //        self.dataSource = self
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        // Setup of our pageView
        
        view.addSubview(scrollView)
        scrollView.backgroundColor = .green
//        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.frame = view.bounds
        scrollView.alwaysBounceHorizontal = false
        scrollView.contentSize = CGSize(width: width * 2, height: height)
        scrollView.bounces = false
        scrollView.addSubview(pageView.view)
//        addChildViewController(pageView)
//        scrollView.addSubview(pageView.view)
//        didMove(toParentViewController: pageView)
        scrollView.delegate = self
        
        
        pageView.delegate = self
        pageView.dataSource = self
        pageView.view.frame = view.bounds
        pageView.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookShelfVC")
        pageView.setViewControllers([vc!], direction: .forward, animated: true, completion: nil)
        
//        let horizontalConstraintForPageView = NSLayoutConstraint(item: pageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
//        let verticalConstraintForPageView = NSLayoutConstraint(item: pageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
//        let widthConstraintForPageView = NSLayoutConstraint(item: pageView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
//        let heightConstraintForPageView = NSLayoutConstraint(item: pageView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
//        view.addConstraints([horizontalConstraintForPageView, verticalConstraintForPageView, widthConstraintForPageView, heightConstraintForPageView])
//
        
        for view in view.subviews {
            if view is UIScrollView {
                (view as! UIScrollView).delegate =  self
                break
            }
        }
        
        
        
        
        // Configure our custom pageControl
        view.addSubview(pageControl)
        pageControl.numberOfPages = pages.count
        pageControl.backgroundColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPage = 0
        pageControl.alpha = 0.5
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        
        // For the design it looks the best if the height and width value are switched
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
        
        
        
        
        
        //        for view in view.subviews {
        //            if view is UIScrollView {
        //                (view as! UIScrollView).delegate = self
        //                break
        //            }
        //        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(1)
//        scrollView.contentOffset = CGPoint(x: 0.0,y: 0.0)
//    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print(2)
    }
    
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(true)
    //
    //        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookShelfVC")
    //        setViewControllers([vc!], direction: .forward, animated: true, completion: nil)
    //
    //    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let identifier = viewController.restorationIdentifier else { return nil }
        guard let index = pages.index(of: identifier) else { return nil }
        pageControl.currentPage = index
        if index > 0 {
            return self.storyboard?.instantiateViewController(withIdentifier: pages[index-1])
        }
        
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        if completed {
            // Get current index
            let pageContentViewController = pageViewController.viewControllers![0].restorationIdentifier
            currentIndex = pages.index(of: pageContentViewController!)!
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastPosition = scrollView.contentOffset.x
        
        if (currentIndex == pages.count - 1) && (lastPosition > scrollView.frame.width) {
            scrollView.contentOffset.x = scrollView.frame.width
            return
            
        } else if currentIndex == 0 && lastPosition < scrollView.frame.width {
            scrollView.contentOffset.x = scrollView.frame.width
            return
        }
    }
    
    
    //    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    //        if completed {
    //            // Get current index
    //            guard let pageContentViewController = pageViewController.viewControllers![0].restorationIdentifier else { print("Couldn't unwrap 'pageViewController.restorationIdentifier"); return }
    //            currentIndex = pages.index(of: pageContentViewController)!
    //
    //        }
    //    }
    
    
    
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //        self.lastPosition = scrollView.contentOffset.x
    //
    //        if (currentIndex == pages.count - 1) && (lastPosition > scrollView.frame.width) {
    //            scrollView.contentOffset.x = scrollView.frame.width
    //            return
    //
    //        } else if currentIndex == 0 && lastPosition < scrollView.frame.width {
    //            scrollView.contentOffset.x = scrollView.frame.width
    //            return
    //        }
    //    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let identifier = viewController.restorationIdentifier else { return nil }
        guard let index = pages.index(of: identifier) else { return nil }
        pageControl.currentPage = index
        
        if index < pages.count - 1 {
            return self.storyboard?.instantiateViewController(withIdentifier: pages[index+1])
        }
        return nil
    }
    
}
