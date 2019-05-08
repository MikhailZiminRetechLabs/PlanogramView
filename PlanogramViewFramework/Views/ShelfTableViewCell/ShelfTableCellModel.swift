//
//  ShelfTableCellModel.swift
//  rebotics_ios
//
//  Created by Alexandr on 07/05/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

open class ShelfTableCellModel {
    
    public let itemDetailsSignal: Signal<IPlanogramItem, NoError>
    private let itemDetailsSignalObserver: Signal<IPlanogramItem, NoError>.Observer

    public init() {
        let (itemDetailsSignal, itemDetailsSignalObserver) = Signal<IPlanogramItem, NoError>.pipe()
        self.itemDetailsSignal = itemDetailsSignal
        self.itemDetailsSignalObserver = itemDetailsSignalObserver
    }
    
    public func select(item: PlanogramItem) {
        self.itemDetailsSignalObserver.send(value: item)
    }
}
