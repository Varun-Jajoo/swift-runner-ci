//
//  CustomPageControl.swift
//  MyPT
//
//  Created by techsaga corp on 13/11/24.
//

import UIKit

class CustomPageControl: UIView {
    
    var numberOfPages: Int = 0 {
        didSet {
            setupDots()
        }
    }

    var currentPage: Int = 0 {
        didSet {
            updateDots()
        }
    }

    var activeDotSize: CGSize = CGSize(width: 8, height: 8) {
        didSet {
            updateDots()
        }
    }

    var dotSize: CGSize = CGSize(width: 8, height: 8) {
        didSet {
            updateDots()
        }
    }

    var defaultDotColor: UIColor = UIColor.gray {
        didSet {
            updateDots()
        }
    }

    var currentDotColor: UIColor = UIColor.red {
        didSet {
            updateDots()
        }
    }

    private var dotViews: [UIView] = []
    private let spacing: CGFloat = 8

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.bounces = false
        return scroll
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
    }

    private func setupScrollView() {
        addSubview(scrollView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        layoutDots()
    }

    private func setupDots() {
        // Remove old dots
        dotViews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()

        // Create and add new dot views
        for i in 0..<numberOfPages {
            let dot = UIView()
            dot.backgroundColor = (i == currentPage) ? currentDotColor : defaultDotColor
            dot.layer.cornerRadius = dotSize.height / 2
            scrollView.addSubview(dot)
            dotViews.append(dot)
        }

        layoutDots()
    }

    private func layoutDots() {
        var xOffset: CGFloat = 0

        for (index, dot) in dotViews.enumerated() {
            let size = (index == currentPage) ? activeDotSize : dotSize
            dot.frame = CGRect(x: xOffset, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
            dot.layer.cornerRadius = size.height / 2
            xOffset += size.width + spacing
        }

        scrollView.contentSize = CGSize(width: xOffset - spacing, height: bounds.height)

        // Optional: Scroll to keep the current page visible
        scrollToCurrentDot()
    }

    private func updateDots() {
        for (index, dot) in dotViews.enumerated() {
            let size = (index == currentPage) ? activeDotSize : dotSize
            dot.backgroundColor = (index == currentPage) ? currentDotColor : defaultDotColor
            dot.frame.size = size
            dot.layer.cornerRadius = size.height / 2
        }

        layoutDots()
    }

    private func scrollToCurrentDot() {
        guard currentPage < dotViews.count else { return }

        let dot = dotViews[currentPage]
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)

        if !visibleRect.contains(dot.frame) {
            scrollView.scrollRectToVisible(dot.frame.insetBy(dx: -16, dy: 0), animated: true)
        }
    }
}


//class CustomPageControl: UIView {
//    
//    var numberOfPages: Int = 0 {
//        didSet {
//            setupDots()
//        }
//    }
//    
//    var currentPage: Int = 0 {
//        didSet {
//            updateDots()
//        }
//    }
//    
//    var activeDotSize: CGSize = CGSize(width: 8, height: 8) {
//        didSet {
//            updateDots()
//        }
//    }
//    
//    var dotSize: CGSize = CGSize(width: 8, height: 8) {
//        didSet {
//            updateDots()
//        }
//    }
//    
//    var defaultDotColor: UIColor = UIColor.gray {
//        didSet {
//            updateDots()
//        }
//    }
//    
//    var currentDotColor: UIColor = UIColor.red {
//        didSet {
//            updateDots()
//        }
//    }
//    
//    private var dotViews: [UIView] = []
//    private let spacing: CGFloat = 8
//    
//    // Initialize dots based on the number of pages
//    private func setupDots() {
//        // Remove old dots
//        dotViews.forEach { $0.removeFromSuperview() }
//        dotViews.removeAll()
//        
//        // Create and add new dot views
//        for i in 0..<numberOfPages {
//            let dot = UIView()
//            dot.layer.cornerRadius = dotSize.height / 2
//            //            dot.backgroundColor = (i == currentPage) ? .blue : .gray
//            dot.backgroundColor = (i == currentPage) ? currentDotColor : defaultDotColor
//            addSubview(dot)
//            dotViews.append(dot)
//        }
//        
//        // Layout dots
//        layoutDots()
//    }
//    
//    // Arrange the dots horizontally with spacing
//
//    private func layoutDots() {
//        // Calculate the total width required by all dots and the spacing between them
//        let totalDotWidth = dotViews.enumerated().reduce(0) { $0 + ((currentPage == $1.offset) ? activeDotSize.width : dotSize.width) }
//        let totalSpacingWidth = CGFloat(numberOfPages - 1) * spacing
//        let totalWidth = totalDotWidth + totalSpacingWidth
//        
//        // Start the xOffset from the left edge, centered within the bounds
//        var xOffset = (self.bounds.width - totalWidth) / 2
//        
//        for (index, dot) in dotViews.enumerated() {
//            // Determine the size for the current dot (active or default)
//            let size = (index == currentPage) ? activeDotSize : dotSize
//            dot.frame = CGRect(x: xOffset, y: (self.bounds.height - size.height) / 2, width: size.width, height: size.height)
//            dot.layer.cornerRadius = size.height / 2
//            
//            // Increment xOffset by the width of the current dot plus spacing
//            xOffset += size.width + spacing
//        }
//    }
//        
//    // Update the appearance of dots when the page changes
//    private func updateDots() {
//        for (index, dot) in dotViews.enumerated() {
//            let size = (index == currentPage) ? activeDotSize : dotSize
//            dot.backgroundColor = (index == currentPage) ? currentDotColor : defaultDotColor // .blue : .gray
//            dot.frame.size = size
//            dot.layer.cornerRadius = size.height / 2
//        }
//        
//        // Re-layout dots to accommodate for active dot resizing
//        layoutDots()
//    }
//}
