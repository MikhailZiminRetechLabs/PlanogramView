//
//  IProduct.swift
//  PlanogramView
//
//  Created by Mikhail Zimin on 25/12/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation

@objc public protocol IProduct {
    
    var smallImage: String? { get set }
    var upc: String  { get set }
    var title: String?  { get set }
    
    var imageUrl: URL?  { get }
}
