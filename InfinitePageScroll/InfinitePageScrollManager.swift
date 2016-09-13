//
//  InfinitePageScrollManager.swift
//  InfinitePageScroll
//
//  Created by extremer on 2016. 9. 12..
//  Copyright © 2016년 sellit. All rights reserved.
//

import Foundation

@objc public protocol InfinitePageScrollDelegate {
    func pageViewForInfo(info: AnyObject) -> UIView
    
    // optional for filtering out setting same infos
    optional func isPageInfoIdentical(newInfo: AnyObject, oldInfo: AnyObject) -> Bool
    
    // control points
    optional func didLoopRight()
    optional func didLoopLeft()
}

@objc public class InfinitePageScrollManager : NSObject, UIScrollViewDelegate {
    public let scrollView: UIScrollView
    public var scrollSize: CGSize
    
    private var infoViews = [UIView]()
    private var lastContentOffsetX: CGFloat?
    
    // MARK: Initialize
    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        scrollView.pagingEnabled = true
        
        scrollView.layoutIfNeeded()
        scrollSize = scrollView.frame.size
    }
    
    // MARK: Interface
    public weak var infinitePageScrollDelegate: InfinitePageScrollDelegate?
    public var pageInfos = [AnyObject]() {
        didSet {
            if let identical = infinitePageScrollDelegate?.isPageInfoIdentical?(pageInfos, oldInfo: oldValue)
            where identical {
                return
            }
            
            layoutInfoViews(pageInfos)
        }
    }

    // scroll position relative to original contents
    public var relativeScrollPosition: CGPoint {
        get {
            // return origin for no contents
            if scrollView.contentSize.width == 0.0 {
                return CGPointZero
            }
            
            let scrollWidth = scrollSize.width
            let relativeContentSize = scrollView.contentSize.width - (2.0*scrollSize.width)
            var relativeOffset = scrollView.contentOffset.x - scrollWidth
            if relativeOffset < 0.0 {
                relativeOffset += relativeContentSize
            }
            else if relativeOffset >= relativeContentSize {
                relativeOffset -= relativeContentSize
            }
            
            return CGPoint(x: relativeOffset, y: scrollView.contentOffset.y)
        }
    }
    
    // MARK: Layout
    private func layoutInfoViews(infos: [AnyObject]) {
        // remove old views
        for infoView in infoViews {
            infoView.removeFromSuperview()
        }
        infoViews.removeAll()
        
        // insert virtual pages
        var manipulatedInfos = infos
        if let last = infos.last {
            manipulatedInfos.insert(last, atIndex: 0)
        }
        
        if let first = infos.first {
            manipulatedInfos.append(first)
        }
        
        // layout
        var prevView: UIView?
        for info in manipulatedInfos {
            var infoView = infinitePageScrollDelegate?.pageViewForInfo(info)
            if infoView == nil {
                infoView = UIView()
                infoView?.translatesAutoresizingMaskIntoConstraints = false
            }
            
            infoView!.addConstraint(NSLayoutConstraint(item: infoView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: scrollSize.width))
            infoView!.addConstraint(NSLayoutConstraint(item: infoView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: scrollSize.height))
            scrollView.addSubview(infoView!)
            scrollView.addConstraint(NSLayoutConstraint(item: infoView!, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1.0, constant: 0.0))
            scrollView.addConstraint(NSLayoutConstraint(item: infoView!, attribute: .Bottom, relatedBy: .Equal, toItem: scrollView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            
            if let leftView = prevView {
                scrollView.addConstraint(NSLayoutConstraint(item: infoView!, attribute: .Leading, relatedBy: .Equal, toItem: leftView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            }
            else {
                scrollView.addConstraint(NSLayoutConstraint(item: infoView!, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            }
            
            infoViews.append(infoView!)
            prevView = infoView!
        }
        
        if let lastView = prevView {
            scrollView.addConstraint(NSLayoutConstraint(item: lastView, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        }
        
        // initial position
        scrollView.setContentOffset(CGPoint(x: scrollSize.width, y: 0.0), animated: false)
    }
    
    // MARK: UIScrollView Delegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        if let lastOffsetX = lastContentOffsetX {
            // loop right
            if contentOffsetX > lastOffsetX &&
                scrollView.contentOffset.x > scrollView.contentSize.width - scrollSize.width {
                print("loop right")
                lastContentOffsetX = nil    // reset before force setting offset(to prevent triggerring loop left)
                scrollView.setContentOffset(CGPoint(x: scrollSize.width, y: 0.0), animated: false)
                
                infinitePageScrollDelegate?.didLoopRight?()
                
                return      // skip setting lastContentOffsetX(already set on above line)
            }
                // loop left
            else if contentOffsetX < lastOffsetX &&
                scrollView.contentOffset.x < 0.0 {
                print("loop left")
                lastContentOffsetX = nil    // reset before force setting offset(to prevent triggerring loop right)
                scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - (2.0*scrollSize.width), y: 0.0), animated: false)
                
                infinitePageScrollDelegate?.didLoopLeft?()
                
                return      // skip setting lastContentOffsetX(already set on above line)
            }
        }
        
        lastContentOffsetX = contentOffsetX
    }
}