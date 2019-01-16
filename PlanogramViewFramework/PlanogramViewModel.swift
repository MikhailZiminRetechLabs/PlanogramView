//
//  PlanogramViewModel.swift
//  Rebotics
//
//  Created by Mikhail Zimin on 25/10/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation
import ReactiveSwift

open class PlanogramViewModel {
    
    public var type: PlanogramViewType = .normal
    public var shelfs = MutableProperty<[PlanogramShelf]>([])
    
    public init() { }
}
