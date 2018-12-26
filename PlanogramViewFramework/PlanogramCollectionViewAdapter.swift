
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
import Result
import Kingfisher

class PlanogramCollectionViewAdapter: NSObject {
    
    var collectionView: UICollectionView!
    var planogramType: PlanogramViewType?
    
    var items = MutableProperty<[IPlanogramItem]>([])
    let selectedItem = MutableProperty<IPlanogramItem?>(nil)
    private var maxItems = 0
    
    public let itemDetailsSignal: Signal<IPlanogramItem, NoError>
    private let itemDetailsSignalObserver: Signal<IPlanogramItem, NoError>.Observer
    
    init(_ cv: UICollectionView) {
        self.collectionView = cv
        
        let (itemDetailsSignal, itemDetailsSignalObserver) = Signal<IPlanogramItem, NoError>.pipe()
        self.itemDetailsSignal = itemDetailsSignal
        self.itemDetailsSignalObserver = itemDetailsSignalObserver
        
        super.init()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCollectionViewCell")
        
        items.signal.observeValues { [weak self] in
            guard let `self` = self else { return }
            for item in $0 {
                if self.maxItems < item.verticalFacings {
                    self.maxItems = item.verticalFacings
                }
            }
            
            self.collectionView.reloadData()
        }
        
        selectedItem.signal.skipNil().observeValues { [weak self] in
            guard let `self` = self else { return }
            
            let item = $0
            let groupedItems = self.items.value.filter { $0.groupHashId == item.groupHashId }
            
            groupedItems.forEach { currentItem in
                if let index = self.items.value.firstIndex(where: { currentItem.position == $0.position }) {
                    let indexPath = IndexPath(item: index, section: 0)
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                        
                        var imageViews = [] as [UIView]
                        cell.stackView.arrangedSubviews.forEach {
                            if let productView = $0 as? ProductPlanogramView {
                                imageViews.append(productView.colorView)
                            }
//                            else if let imageView = $0 as? UIImageView {
//                                imageViews.append(imageView)
//                            }
                        }
                        
                        
                        
                        imageViews.forEach {
                            let fillColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
                            fillColorAnimation.duration = 0.2
                            fillColorAnimation.toValue = UIColor.red.withAlphaComponent(1).cgColor
                            fillColorAnimation.repeatCount = 2
                            fillColorAnimation.fillMode = CAMediaTimingFillMode.forwards
                            
                            fillColorAnimation.autoreverses = true
                            fillColorAnimation.isRemovedOnCompletion = false
                            $0.layer.add(fillColorAnimation, forKey: "backgroundColor")
                        }
                    }
                }
            }
        }
        
    }
    
    private func runBlinkViewAnimation(of planogramItems: [IPlanogramItem]) {
        planogramItems.forEach { currentItem in
            if let index = self.items.value.firstIndex(where: { currentItem.position == $0.position }) {
                let indexPath = IndexPath(item: index, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                    
                    var imageViews = [] as [UIView]
                    cell.stackView.arrangedSubviews.forEach {
                        if let productView = $0 as? ProductPlanogramView {
                            imageViews.append(productView.colorView)
                        }
                    }
                    
                    imageViews.forEach {
                        self.runBlinkViewAnimation(of: $0)
                    }
                }
            }
        }
    }
    
    private func runBlinkViewAnimation(of view: UIView) {
        let fillColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        fillColorAnimation.duration = 0.2
        fillColorAnimation.toValue = UIColor.white.withAlphaComponent(0.8).cgColor
        fillColorAnimation.repeatCount = 2
        fillColorAnimation.fillMode = CAMediaTimingFillMode.forwards
        fillColorAnimation.autoreverses = true
        fillColorAnimation.isRemovedOnCompletion = false
        view.layer.add(fillColorAnimation, forKey: "backgroundColor")
        
    }
}


extension PlanogramCollectionViewAdapter: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
                    productView.imageView.kf.setImage(with: imageURL, placeholder: nil, options: [.targetCache(.init(name: "cache"))], progressBlock: nil) { (image, error, cacheType, url) in
                    }
                } else {
                    productView.imageView.backgroundColor = UIColor.gray
                    productView.imageView.image = UIImage(named: "ic_no_planogram_image")
                }
                
                cell.stackView.addArrangedSubview(productView)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / CGFloat(items.value.count),
                      height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items.value[indexPath.row]

        itemDetailsSignalObserver.send(value: item)
        
        let blinkedItems = items.value.map { $0 }.filter { $0.groupHashId == item.groupHashId }
        runBlinkViewAnimation(of: blinkedItems)

        
        
//        if missingProducts.value.count > 0 {
//            if (missingProducts.value.map { $0.id }.contains(item.id)) {
//                self.selectedItem.value = item
//
//                ScreenRouter.shared.currentViewController?.present(.planogramItemDetail(itemId: item.id),
//                                                                   transitioningDelegate: transitionDelegate,
//                                                                   interactor: transitionDelegate.interactor,
//                                                                   force: true)
//            }
//
//
//            return
//        }
//
//
//        if let type = planogramType, type == .normal ||
//            (ScreenRouter.shared.currentViewController as? ComplianceVC)?.type == .normal {
//            ScreenRouter.shared.currentViewController?.present(.planogramItemDetail(itemId: item.id),
//                                                         transitioningDelegate: transitionDelegate,
//                                                         interactor: transitionDelegate.interactor,
//                                                         force: true)
//
//
//
//            let blinkedItems = items.value.map { $0 }.filter { $0.groupHashId == item.groupHashId }
//            runBlinkViewAnimation(of: blinkedItems)
//        } else {
//            itemDetailsSignalObserver.send(value: item)
//
//            let blinkedItems = actionReportItemsByUpcs.map { $0.value }.filter { $0.planogramItem?.groupHashId == item.groupHashId }.filter { $0.planogramItem != nil } .map { $0.planogramItem! }
//            runBlinkViewAnimation(of: blinkedItems)
//        }
        
    }
}
