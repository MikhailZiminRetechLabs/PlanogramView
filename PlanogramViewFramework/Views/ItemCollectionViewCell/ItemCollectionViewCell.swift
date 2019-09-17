//
//  ItemCollectionViewCell.swift
//  rebotics_ios
//
//  Created by Mikhail on 16/04/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import UIKit

open class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet public weak var stackView: UIStackView!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillEqually
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        for subview in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

}
