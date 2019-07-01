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
    @IBOutlet public weak var tableWidthConstraint: NSLayoutConstraint!
    @IBOutlet public weak var tableLeadingConstraint: NSLayoutConstraint!
    
    let _model = PlanogramViewModel()
    
    var scrollViewAdapter: ScrollViewAdapter!
    public var tableViewAdapter: PlanogramTableViewAdapter!
    
    public let selectedItem = MutableProperty<PlanogramItem?>(nil)
    
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
            
            let heightConst = (self.scrollView.frame.height - $0) / 2
            if heightConst >= 0 {
                self.tableTopConstraint.constant = heightConst
            } else {
                self.tableTopConstraint.constant = 0
            }
        }
        
        scrollViewAdapter.zoomViewFrameWidth.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            let widthConst = (self.scrollView.frame.width - $0) / 2
            if widthConst >= 0 {
                self.tableLeadingConstraint.constant = widthConst
            } else {
                self.tableLeadingConstraint.constant = 0
            }
        }
        
        tableViewAdapter.tableSize.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            let scrollViewFrameRatio = self.scrollView.frame.width / self.scrollView.frame.height
            let tableViewFrameRation = $0.width / $0.height
            let isHorizontal = scrollViewFrameRatio < tableViewFrameRation
            if isHorizontal {
                let horizontalRatio = $0.width / self.scrollView.frame.width
                let tableViewActualHeight = $0.height / horizontalRatio
                self.tableHeightConstraint.constant = tableViewActualHeight
                let const = (self.scrollView.frame.height - tableViewActualHeight) / 2
                if const >= 0 {
                    self.tableTopConstraint.constant = const
                } else {
                    self.tableTopConstraint.constant = 0
                }
                
                self.tableWidthConstraint.constant = self.scrollView.frame.width
                self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: tableViewActualHeight)
                self.layoutIfNeeded()
            } else {
                let verticalRatio = $0.height / self.scrollView.frame.height
                let tableViewActualWidth = $0.width / verticalRatio
                self.tableWidthConstraint.constant = tableViewActualWidth
                let const = (self.scrollView.frame.width - tableViewActualWidth) / 2
                if const >= 0 {
                    self.tableLeadingConstraint.constant = const
                } else {
                    self.tableLeadingConstraint.constant = 0
                }
                
                self.tableHeightConstraint.constant = self.scrollView.frame.height
                self.scrollView.contentSize = CGSize(width: tableViewActualWidth, height: self.scrollView.contentSize.height)
                self.layoutIfNeeded()
            }
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
