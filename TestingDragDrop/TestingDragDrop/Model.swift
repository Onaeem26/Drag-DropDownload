//
//  Model.swift
//  TestingDragDrop
//
//  Created by Osama Naeem on 11/01/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import UIKit
import MobileCoreServices


struct Model {
    
    var productName = [
        "iPhone",
        "iPad",
        "Macbook",
        "Apple Watch"
    ]
    
    var itemsInDragArray : [UIDragItem] = []
    
    mutating func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let productName = self.productName[indexPath.row]
        
        let data = productName.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            
            completion(data, nil)
            
            return nil
        }
        itemsInDragArray = [(UIDragItem(itemProvider: itemProvider))]
        return itemsInDragArray
    }
    
    func dragItemsArray() -> [UIDragItem] {
        return itemsInDragArray
    }
    
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    mutating func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        let product = productName[sourceIndex]
        productName.remove(at: sourceIndex)
        productName.insert(product, at: destinationIndex)
    }
    
    mutating func addItem(_ product: String, at index: Int) {
        productName.insert(product, at: index)
    }
}
