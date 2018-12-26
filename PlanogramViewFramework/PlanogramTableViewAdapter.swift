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

class PlanogramTableViewAdapter: NSObject {
    
    var tableView: UITableView!
    
    var cellHeight: CGFloat = 100
    var totalElements = 0
    var tableHeight = MutableProperty<CGFloat>(0)
    
    var model: PlanogramViewModel
    
    public let itemDetailsSignal: Signal<IPlanogramItem, NoError>
    private let itemDetailsSignalObserver: Signal<IPlanogramItem, NoError>.Observer

    init(_ tv: UITableView, model: PlanogramViewModel) {
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
        tableView.register(UINib(nibName: "ShelfTableViewCell", bundle: nil), forCellReuseIdentifier: "shelfCell")
        
        model.shelfs.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            
            self.totalElements = 0
            self.cellHeight = 100
            var maxItemsShelfs = 0
            
            for shelf in $0 {
                var maxItems = 0
                
                for item in shelf.items {
                    if maxItems < item.verticalFacings {
                        maxItems = item.verticalFacings
                    }
                }
                if maxItemsShelfs < shelf.items.count {
                    maxItemsShelfs = shelf.items.count
                }
                
                self.totalElements += maxItems
            }
            
            if (maxItemsShelfs == 0) {
                maxItemsShelfs = 1
            }
            
            let tableRation = CGFloat(self.totalElements) / CGFloat(maxItemsShelfs)
            self.cellHeight *= tableRation
            
            let cellHeightRationScreen = self.tableView.frame.size.height / CGFloat(self.totalElements)
            if cellHeightRationScreen < self.cellHeight {
                self.cellHeight = cellHeightRationScreen
            }
            
            self.tableView.reloadData()
            
            if self.totalElements == 0 {
                self.totalElements = 1
            }
            
            self.tableHeight.value = CGFloat(self.totalElements) * self.cellHeight
            
        }
    }
}

extension PlanogramTableViewAdapter: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.shelfs.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "shelfCell", for: indexPath) as? ShelfTableViewCell {
            cell.updateCell(for: model.shelfs.value[indexPath.row].items, planogramType: model.type)
            
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
