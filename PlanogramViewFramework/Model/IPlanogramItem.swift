//
//  IPlanogramItem.swift
//  PlanogramView
//
//  Created by Mikhail Zimin on 25/12/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation

@objc public protocol IPlanogramItem {
    
    var shelf: Int { get set }
    var position: Int { get set }
    var verticalFacings: Int { get set }
    
    @objc optional var product: IProduct { get set }
    
    var groupHashId: String { get }
}
