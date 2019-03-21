//
//  IPlanogramItem.swift
//  PlanogramView
//
//  Created by Mikhail Zimin on 25/12/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation

public protocol IPlanogramItem {
    
    var shelf: Int { get set }
    var position: Int { get set }
    var verticalFacings: Int { get set }
    
    var _product: IProduct? { get }
}
