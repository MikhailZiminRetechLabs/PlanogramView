//
//  IPlanogramItem.swift
//  PlanogramView
//
//  Created by Mikhail Zimin on 25/12/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation

open class PlanogramItem: NSObject {
    
    public var shelf: Int = 0
    public var position: Int = 0
    public var verticalFacings: Int = 0
    
    open var product: IProduct?
}
