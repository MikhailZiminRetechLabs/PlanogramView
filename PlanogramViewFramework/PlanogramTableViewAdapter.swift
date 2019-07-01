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
//import Result

open class PlanogramTableViewAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public var tableView: UITableView!
    public var tableSize = MutableProperty<CGSize>(.zero)
    
    let model: PlanogramViewModel
    
    public let itemDetailsSignal: Signal<PlanogramItem, Never>
    public let itemDetailsSignalObserver: Signal<PlanogramItem, Never>.Observer
    
    public init(_ tv: UITableView, model: PlanogramViewModel) {
        (itemDetailsSignal, itemDetailsSignalObserver) = Signal<PlanogramItem, Never>.pipe()
        
        self.model = model
        self.tableView = tv
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
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
            
            let planogramSizeService = PlanogramSizeService()
            self.tableSize.value = planogramSizeService.getPlanogramSize(by: $0)
            self.tableView.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.shelfs.value.count
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let countsProductsInShelf = model.shelfs.value.map { $0.items.map { item in item.verticalFacings }.max() ?? 0 }
        let countProductsInColumn = countsProductsInShelf.reduce(0) { $0 + $1 }
        let cellHeight = tableView.frame.height / CGFloat(countProductsInColumn)
        
        let shelf = model.shelfs.value[indexPath.row]
        let maxItems = shelf.items.map { $0.verticalFacings }.max() ?? 0
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

