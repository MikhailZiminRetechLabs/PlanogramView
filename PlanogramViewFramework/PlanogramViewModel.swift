//
//  PlanogramViewModel.swift
//  Rebotics
//
//  Created by Mikhail Zimin on 25/10/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation
import ReactiveSwift

class PlanogramViewModel {
    
    var type: PlanogramViewType = .normal

    var shelfs = MutableProperty<[PlanogramShelf]>([])
}
