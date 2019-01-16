//
//  PlanogramShelfTableViewCell.swift
//  rebotics_ios
//
//  Created by Mikhail on 16/04/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import UIKit
import Kingfisher
import ReactiveSwift
import Result

open class ShelfTableViewCell: UITableViewCell {

    @IBOutlet public weak var collectionView: UICollectionView!
    
    var collectionViewAdapter: PlanogramCollectionViewAdapter?
    public let model = MutableProperty<ShelfTableCellModel?>(nil)
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        collectionViewAdapter = PlanogramCollectionViewAdapter(collectionView)
        
        model.signal.observeValues{ [weak self] in self?.setModel($0)}
    }
    
    open func setModel(_ model: ShelfTableCellModel?) {
        guard let model = model, let collectionViewAdapter = self.collectionViewAdapter else {
            return
        }
        
        collectionViewAdapter.itemDetailsSignal.observeValues { [weak model] in
            model?.select(item: $0)
        }
    }

    public func updateCell(for items: [IPlanogramItem], planogramType: PlanogramViewType) {
        collectionViewAdapter?.planogramType = planogramType
        collectionViewAdapter?.items.value = items
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
    }
}
