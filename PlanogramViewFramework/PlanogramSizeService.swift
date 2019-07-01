//
//  PlanogramSizeService.swift
//  PlanogramView
//
//  Created by Mikhail Zimin on 01/07/2019.
//

import Foundation

class PlanogramSizeService {
    
    func getPlanogramSize(by shelfs: [PlanogramShelf]) -> CGSize {
        let standardProductSize = CGSize(width: 100, height: 100)
        let maxCountProductsInShelf = shelfs.map { $0.items.count }.max() ?? 0
        let countsProductsInShelf = shelfs.map { $0.items.map { item in item.verticalFacings }.max() ?? 0 }
        let countProductsInColumn = countsProductsInShelf.reduce(0) { $0 + $1 }
        
        return CGSize(width: standardProductSize.width * CGFloat(maxCountProductsInShelf),
                      height: standardProductSize.height * CGFloat(countProductsInColumn))
    }
}
