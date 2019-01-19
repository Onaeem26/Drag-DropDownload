//
//  PodcastModel .swift
//  TestingDragDrop
//
//  Created by Osama Naeem on 17/01/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import UIKit
import MobileCoreServices

 class descriptiveJSON: Codable {
  
    
    
    let resultCount: Int?
    var results : [podcastModelData]
    
 
}

final class podcastModelData: NSObject, Codable, NSItemProviderReading, NSItemProviderWriting {
   
    
    
    var collectionName : String?
    var feedUrl: String?
    var artworkUrl100: String?
    
     init(collectionName: String, feedURL: String, artworkURL100: String) {
        self.collectionName = collectionName
        self.feedUrl = feedURL
        self.artworkUrl100 = artworkURL100
    }
   
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        
        let progress = Progress(totalUnitCount: 100)
        
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            let json = String(data: data, encoding: String.Encoding.utf8)
            progress.completedUnitCount = 100
            completionHandler(data, nil)
        } catch {
     
            completionHandler(nil, error)
        }
        
        return progress
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [(kUTTypeData) as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> podcastModelData {
        let decoder = JSONDecoder()
        do {
            let myJSON = try decoder.decode(podcastModelData.self, from: data)
            return myJSON
        } catch {
            fatalError("Err")
        }
        
    }
    
   
    
}





