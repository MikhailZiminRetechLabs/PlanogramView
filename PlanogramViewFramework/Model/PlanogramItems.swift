//
//  Planogram.swift
//  PlanogramView
//
//  Created by Mikhail Zimin on 25/12/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation

public class PlanogramItems {
    
    public var shelfs: [PlanogramShelf] = []
    public var items: [PlanogramItem] = []
    
    public init(items: [PlanogramItem]) {
        self.items = items
        
        let numberOfShelfs = items.map { $0.shelf }
            .sorted(by: { $0 < $1 })
            .last ?? 0
        
        if numberOfShelfs == 0 {
            return
        }
        
        for i in 1...numberOfShelfs {
            let shelf = PlanogramShelf()
            shelf.shelfNumber = i
            shelfs.append(shelf)
        }
        
        for item in items {
            let shelf = shelfs[item.shelf - 1]
            shelf.items.append(item)
        }
    }
}
