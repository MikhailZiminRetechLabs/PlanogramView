//
//  PlanogramView.swift
//  Rebotics
//
//  Created by Mikhail Zimin on 25/10/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import UIKit
import ReactiveSwift


enum PlanogramViewType {
    case normal
    case embed
}

class PlanogramView: UIView {

    @IBOutlet fileprivate var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    
    let model = PlanogramViewModel()
    
    var scrollViewAdapter: ScrollViewAdapter!
    var tableViewAdapter: PlanogramTableViewAdapter!
    let selectedItem = MutableProperty<IPlanogramItem?>(nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit () {
        Bundle.main.loadNibNamed("PlanogramView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        setupUI()
    }
    
    private func setupUI() {
        scrollViewAdapter = ScrollViewAdapter(scrollView, zoomingView: tableView)
        tableViewAdapter = PlanogramTableViewAdapter(tableView, model: model)
        
        tableViewAdapter.tableHeight.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            self.tableHeightConstraint.constant = $0
//            self.tableTopConstraint.constant = (self.scrollView.frame.height - $0) / 2
            let const = (self.scrollView.frame.height - $0) / 2
            if const >= 0 {
                self.tableTopConstraint.constant = const
            } else {
                self.tableTopConstraint.constant = 0
            }
            self.layoutIfNeeded()
        }
        
        
        scrollViewAdapter.zoomViewFrameHeight.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            let const = (self.scrollView.frame.height - $0) / 2
            if const >= 0 {
                self.tableTopConstraint.constant = const
            } else {
                self.tableTopConstraint.constant = 0
            }
        }
        
        tableViewAdapter.itemDetailsSignal.observeValues { [weak self] in
            self?.selectedItem.value = $0
        }
        
    }
    
}
