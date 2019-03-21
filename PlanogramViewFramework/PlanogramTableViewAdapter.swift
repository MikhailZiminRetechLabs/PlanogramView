//
//  PlanogramTableViewAdapter.swift
//  rebotics_ios
//
//  Created by Mikhail on 16/04/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

open class PlanogramTableViewAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public var tableView: UITableView!
    
    var cellHeight: CGFloat = 100
    var maxItemsShelfs = 0
    var totalElements = 0
    public var tableHeight = MutableProperty<CGFloat>(0)
    
    let model: PlanogramViewModel
    
    public let itemDetailsSignal: Signal<IPlanogramItem, NoError>
    public let itemDetailsSignalObserver: Signal<IPlanogramItem, NoError>.Observer
    
    public init(_ tv: UITableView, model: PlanogramViewModel) {
        let (itemDetailsSignal, itemDetailsSignalObserver) = Signal<IPlanogramItem, NoError>.pipe()
        self.itemDetailsSignal = itemDetailsSignal
        self.itemDetailsSignalObserver = itemDetailsSignalObserver
        
        self.model = model
        self.tableView = tv
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: .zero)
        
        if let path = Bundle(for: ShelfTableViewCell.self).path(forResource: "PlanogramView", ofType: "bundle") {
            let podBundle = Bundle(path: path)
            
            let cellNib = UINib(nibName: "ShelfTableViewCell", bundle: podBundle)
            tableView.register(cellNib, forCellReuseIdentifier: "ShelfTableViewCell")
        } else {
            print("Could not create a path to the bundle")
        }
        
        model.shelfs.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            self.totalElements = 0
            self.maxItemsShelfs = 0
            
            for shelf in $0 {
                var maxItems = 0
                
                for item in shelf.items {
                    if maxItems < item.verticalFacings {
                        maxItems = item.verticalFacings
                    }
                }
                if self.maxItemsShelfs < shelf.items.count {
                    self.maxItemsShelfs = shelf.items.count
                }
                
                self.totalElements += maxItems
            }
            
            if self.maxItemsShelfs == 0 {
                self.maxItemsShelfs = 1
            }
            
            if self.totalElements == 0 {
                self.totalElements = 1
            }
            
            self.cellHeight = UIScreen.main.bounds.width / CGFloat(self.maxItemsShelfs)
            
            let cellHeightRatioScreen = (UIScreen.main.bounds.height - 100) / CGFloat(self.totalElements)
            if cellHeightRatioScreen < self.cellHeight {
                self.cellHeight = cellHeightRatioScreen
            }
            
            if self.cellHeight > 150 {
                self.cellHeight = 150
            }
            
            self.tableHeight.value = CGFloat(self.totalElements) * self.cellHeight
            
            self.tableView.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.shelfs.value.count
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var maxItems = 0
        
        let shelf = model.shelfs.value[indexPath.row]
        for item in shelf.items {
            if maxItems < item.verticalFacings {
                maxItems = item.verticalFacings
            }
        }
        
        let height = CGFloat(maxItems) * cellHeight
        
        return height
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ShelfTableViewCell", for: indexPath) as? ShelfTableViewCell {
            cell.updateCell(for: model.shelfs.value[indexPath.row].items)
            
            let cellModel = ShelfTableCellModel()
            cellModel.itemDetailsSignal.observeValues { [weak self] in
                self?.itemDetailsSignalObserver.send(value: $0)
            }
            
            cell.model.value = cellModel
            
            return cell
        }
        
        return UITableViewCell()
    }
}

