//
//  ViewController.swift
//  InfinitePageScrollExample
//
//  Created by extremer on 2016. 9. 13..
//  Copyright © 2016년 extremer. All rights reserved.
//

import UIKit
import InfinitePageScroll

class ViewController: UIViewController, UIScrollViewDelegate, InfinitePageScrollDelegate {

    // first time layoutSubviews flag
    var firstTimeLayout = false
    
    // intinite page scroll manager
    private var scrollManager: InfinitePageScrollManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstTimeLayout {
            return
        }
        
        firstTimeLayout = true
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        let topConstraint = NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let leadingConstraint = NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: scrollView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        view.addConstraints([topConstraint, leadingConstraint, bottomConstraint, trailingConstraint])
        
        scrollManager = InfinitePageScrollManager(scrollView: scrollView)
        scrollManager.infinitePageScrollDelegate = self
        
        // set page info
        let info = [UIColor.whiteColor(), UIColor.lightGrayColor(), UIColor.darkGrayColor(), UIColor.brownColor(), UIColor.blackColor()]
        scrollManager.pageInfos = info
    }

    // MARK: InfinitePageScroll Delegate
    func pageViewForInfo(info: AnyObject) -> UIView {
        guard let color = info as? UIColor else {
            return UIView()
        }
        
        let infoView = UIView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = color

        return infoView
    }
    
    func isPageInfoIdentical(newInfo: AnyObject, oldInfo: AnyObject) -> Bool {
        guard let newInfo = newInfo as? [UIColor], oldInfo = oldInfo as? [UIColor] else {
            return false
        }
        
        return newInfo == oldInfo
    }
    
    func didLoopLeft() {
        print("received loop left")
    }
    
    func didLoopRight() {
        print("received loop right")
    }
    
    // MARK: UIScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollManager.scrollViewDidScroll(scrollView)
    }
}

