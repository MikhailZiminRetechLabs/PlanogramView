//
//  PlanogramView.swift
//  Rebotics
//
//  Created by Mikhail Zimin on 25/10/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import UIKit
import ReactiveSwift

open class PlanogramView: UIView {
    
    @IBOutlet fileprivate var contentView: UIView!
    @IBOutlet public weak var scrollView: UIScrollView!
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet public weak var tableTopConstraint: NSLayoutConstraint!
    
    let _model = PlanogramViewModel()
    
    var scrollViewAdapter: ScrollViewAdapter!
    public var tableViewAdapter: PlanogramTableViewAdapter!
    
    public let selectedItem = MutableProperty<IPlanogramItem?>(nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit () {
        if let path = Bundle(for: PlanogramView.self).path(forResource: "PlanogramView", ofType: "bundle") {
            let podBundle = Bundle(path: path)
            
            let viewNib = UINib(nibName: "PlanogramView", bundle: podBundle)
            if let view = viewNib.instantiate(withOwner: self, options: nil).first as? UIView {
                self.contentView = view
            } else {
                print("Counld not create a view")
            }
        } else {
            print("Could not create a path to the bundle")
        }
        
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        setupUI()
    }
    
    open func setupUI() {
        scrollViewAdapter = ScrollViewAdapter(scrollView, zoomingView: tableView)
        tableViewAdapter = PlanogramTableViewAdapter(tableView, model: _model)
        
        scrollViewAdapter.zoomViewFrameHeight.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            let const = (self.scrollView.frame.height - $0) / 2
            if const >= 0 {
                self.tableTopConstraint.constant = const
            } else {
                self.tableTopConstraint.constant = 0
            }
        }
        
        tableViewAdapter.tableHeight.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            self.tableHeightConstraint.constant = $0
            let const = (self.scrollView.frame.height - $0) / 2
            if const >= 0 {
                self.tableTopConstraint.constant = const
            } else {
                self.tableTopConstraint.constant = 0
            }
            self.layoutIfNeeded()
        }
        
        tableViewAdapter.itemDetailsSignal.observeValues { [weak self] in
            self?.selectedItem.value = $0
        }
        
    }
    
    open func setupPlanogram(_ items: [PlanogramItem]) {
        let planogramItems = PlanogramItems(items: items)
        _model.shelfs.value = planogramItems.shelfs
    }
    
}
