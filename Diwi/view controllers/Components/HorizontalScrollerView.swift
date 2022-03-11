import Foundation
import UIKit

protocol HorizontalScrollerViewDataSource {
    func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
    
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView
}

protocol HorizontalScrollerViewDelegate {
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int, view: UIView)
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didScrollViewTo index: Int)
}

class HorizontalScrollerView: UIView, UIScrollViewDelegate {
    
    var dataSource: HorizontalScrollerViewDataSource?
    var delegate: HorizontalScrollerViewDelegate?
    
    var currentShownIndex = 0
    var isScrollEnabled = false {
        didSet {
            scroller.isScrollEnabled = isScrollEnabled
        }
    }
    var isTapEnabled = true
    
    enum ViewConstants {
        static let Padding: CGFloat = 0
        static let Dimensions: CGFloat = 150
        static let Offset: CGFloat = 0
    }
    
    private let scroller = UIScrollView()
    
    private var contentViews = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeScrollView()
    }
    
    func initializeScrollView() {
        scroller.delegate = self
        scroller.contentSize.width = (UIScreen.main.bounds.width * 4)
        
        addSubview(scroller)
        
        scroller.translatesAutoresizingMaskIntoConstraints = false
        scroller.showsHorizontalScrollIndicator = false
        scroller.isScrollEnabled = isScrollEnabled
        
        NSLayoutConstraint.activate([
            scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scroller.topAnchor.constraint(equalTo: self.topAnchor),
            scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gesture:)))
        scroller.addGestureRecognizer(tapRecognizer)
    }
    
    func scrollToView(at index: Int, animated: Bool = true) {
        let centralView = contentViews[index]
        let targetCenter = centralView.center
        currentShownIndex = index
        let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
        scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
    }
    
    @objc func scrollerTapped(gesture: UITapGestureRecognizer) {
        guard isTapEnabled else { return }
        
        let location = gesture.location(in: scroller)
        guard let index = contentViews.firstIndex(where: { $0.frame.contains(location) })
            else { return }
        
        delegate?.horizontalScrollerView(self, didSelectViewAt: index, view: contentViews[index])
    }
    
    func view(at index :Int) -> UIView {
        return contentViews[index]
    }
    
    func reload(_ offset: CGFloat = 16) {
        
        guard let dataSource = dataSource else {
            return
        }
        
        contentViews.forEach { $0.removeFromSuperview() }
        
        var xValue = offset
        
        contentViews = (0..<dataSource.numberOfViews(in: self)).map { index in
            
            xValue += 0
            let view = dataSource.horizontalScrollerView(self, viewAt: index)
            
            view.frame = CGRect(x: CGFloat(xValue),
                                y: ViewConstants.Padding,
                                width: view.frame.size.width,
                                height: view.frame.size.height)
            
            scroller.addSubview(view)
             
            xValue += view.frame.size.width + 8
            return view
            
        }
        
        scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
    }
    
    func resizeContent() {
        var xValue: CGFloat = 8
        
        for view in contentViews {
            
            xValue += 0
            
            view.frame = CGRect(x: CGFloat(xValue),
                                y: ViewConstants.Padding,
                                width: view.frame.size.width,
                                height: view.frame.size.height)
            
            xValue += view.frame.size.width + 8
            
        }
        
        scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        
        setContentOffset(scrollView: scrollView)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setContentOffset(scrollView: scrollView)
    }
    
    func setContentOffset(scrollView: UIScrollView) {
        
        let numOfItems = contentViews.count
        let stopOver = scrollView.contentSize.width / CGFloat(numOfItems)
        let x = round(scrollView.contentOffset.x / stopOver) * stopOver
        
        let centerRect = CGRect(
            origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding, y: 0),
            size: CGSize(width: ViewConstants.Padding, height: bounds.height)
        )
        
        guard let selectedIndex = contentViews.firstIndex(where: { $0.frame.intersects(centerRect) }) else { return }
        
        currentShownIndex = selectedIndex
        
        guard x >= 0 && x <= scrollView.contentSize.width - scrollView.frame.width else {
            return
        }
        
        scrollView.setContentOffset(CGPoint(x: x, y: scrollView.contentOffset.y), animated: true)
        delegate?.horizontalScrollerView(self, didScrollViewTo: selectedIndex)
    }
}


