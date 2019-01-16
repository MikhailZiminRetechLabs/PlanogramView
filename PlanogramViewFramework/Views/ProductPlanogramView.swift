//
//  ProductPlanogramView.swift
//  rebotics_ios
//
//  Created by Alexandr on 08/05/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import UIKit

public class ProductPlanogramView: UIView {

    var imageView: UIImageView!
    public var colorView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: self.bounds)
        colorView = UIView(frame: self.bounds)
        
        addSubview(imageView)
        addSubview(colorView)
        
//        colorView.isHidden = true
        colorView.backgroundColor = UIColor.clear
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        bringSubviewToFront(colorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
