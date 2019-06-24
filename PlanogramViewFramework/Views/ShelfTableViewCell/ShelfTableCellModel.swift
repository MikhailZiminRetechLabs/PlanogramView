//
//  ShelfTableCellModel.swift
//  rebotics_ios
//
//  Created by Alexandr on 07/05/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation
import ReactiveSwift
//import Result

open class ShelfTableCellModel {
    
    public let itemDetailsSignal: Signal<PlanogramItem, Never>
    private let itemDetailsSignalObserver: Signal<PlanogramItem, Never>.Observer

    public init() {
        (itemDetailsSignal, itemDetailsSignalObserver) = Signal<PlanogramItem, Never>.pipe()
    }
    
    public func select(item: PlanogramItem) {
        self.itemDetailsSignalObserver.send(value: item)
    }
}
