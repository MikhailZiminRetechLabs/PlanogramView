
//
//  PlanogramCollectionViewAdapter.swift
//  rebotics_ios
//
//  Created by Mikhail on 16/04/2018.
//  Copyright © 2018 RetechLabs. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Kingfisher

open class PlanogramCollectionViewAdapter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var collectionView: UICollectionView!
    
    public var items = MutableProperty<[PlanogramItem]>([])
    let selectedItem = MutableProperty<PlanogramItem?>(nil)
    private var maxItems = 0
    
    public let itemDetailsSignal: Signal<PlanogramItem, Never>
    private let itemDetailsSignalObserver: Signal<PlanogramItem, Never>.Observer
    
    public init(_ cv: UICollectionView) {
        self.collectionView = cv
        
        (itemDetailsSignal, itemDetailsSignalObserver) = Signal<PlanogramItem, Never>.pipe()
        
        super.init()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let path = Bundle(for: ItemCollectionViewCell.self).path(forResource: "PlanogramView", ofType: "bundle") {
            let podBundle = Bundle(path: path)

            let cellNib = UINib(nibName: "ItemCollectionViewCell", bundle: podBundle)
            collectionView.register(cellNib, forCellWithReuseIdentifier: "ItemCollectionViewCell")
        } else {
            print("Could not create a path to the bundle")
        }

        items.signal.observeValues { [weak self] in
            for item in $0 {
                if self!.maxItems < item.verticalFacings {
                    self?.maxItems = item.verticalFacings
                }
            }
            
            self?.collectionView.reloadData()
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.value.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCollectionViewCell", for: indexPath) as! ItemCollectionViewCell
        let item = items.value[indexPath.row]
        
        // it is important to follow the order of these two cycles: begin
        if item.verticalFacings < maxItems {
            for _ in item.verticalFacings...maxItems - 1 {
                let imageView = UIImageView()
                imageView.backgroundColor = UIColor.clear
                cell.stackView.addArrangedSubview(imageView)
            }
        }
        
        for _ in 0...item.verticalFacings - 1 {
            let height = collectionView.frame.height/CGFloat(maxItems)
            let width = collectionView.frame.width/CGFloat(items.value.count) - 5
            
            let productView = ProductPlanogramView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            productView.imageView.contentMode = .scaleAspectFit
            if let product = item.product {
                if let imageURL = product.imageUrl {
                    let resource = ImageResource(downloadURL: imageURL, cacheKey: imageURL.lastPathComponent)
                    productView.imageView.kf.setImage(with: resource)
                } else {
                    productView.imageView.backgroundColor = UIColor.gray
                    productView.imageView.image = UIImage(named: "ic_no_planogram_image")
                }
                
                cell.stackView.addArrangedSubview(productView)
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {      
        return CGSize(width: collectionView.frame.width / CGFloat(items.value.count),
                      height: collectionView.frame.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items.value[indexPath.row]
        
        itemDetailsSignalObserver.send(value: item)
    }
}
