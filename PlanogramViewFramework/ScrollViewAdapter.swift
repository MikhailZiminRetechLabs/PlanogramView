//
//  PlanogramScrollViewAdapter.swift
//  rebotics_ios
//
//  Created by Mikhail on 16/04/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

class ScrollViewAdapter: NSObject {
    
    var scroll: UIScrollView!
    var zoomingView: UIView!
    var zoomViewFrameHeight = MutableProperty<CGFloat>(0)
    var zoomViewFrameWidth = MutableProperty<CGFloat>(0)
    
    init(_ sv: UIScrollView, zoomingView: UIView) {
        
        scroll = sv
        self.zoomingView = zoomingView
        
        super.init()
        
        scroll.delegate = self
        scroll.maximumZoomScale = 1.0
        scroll.maximumZoomScale = 6.0
        scroll.isUserInteractionEnabled = true
        
        scroll.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "planogram_background"))
    }
}

extension ScrollViewAdapter: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return zoomingView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let verticalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as! UIImageView)
        verticalIndicator.backgroundColor = UIColor(red: 0, green: 94 / 255, blue: 142 / 255, alpha: 1)
        
        let horizontalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 2)] as! UIImageView)
        horizontalIndicator.backgroundColor = UIColor(red: 0, green: 94 / 255, blue: 142 / 255, alpha: 1)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        zoomViewFrameHeight.value = zoomingView.frame.height
        zoomViewFrameWidth.value = zoomingView.frame.width
    }
}
