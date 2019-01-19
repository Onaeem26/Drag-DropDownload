//
//  JSONData.swift
//  TestingDragDrop
//
//  Created by Osama Naeem on 17/01/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import UIKit
import Foundation

class fetchJSON {
    
    static func getNetworkCall(searchQuery: String, completion: @escaping ([podcastModelData]) -> ())  {
        let searchque = searchQuery.replacingOccurrences(of: " ", with: "+")
        let baseURL = "https://itunes.apple.com/search?term=+\(searchque)"
        
        
        guard let podcastURl = URL(string: baseURL) else { return }
        
        var podcastsItems : [podcastModelData] = []
        
        URLSession.shared.dataTask(with: podcastURl) { (data, response, error) in
            guard let data = data else { return }
            do {
                
               
                let podcastDescriptions = try JSONDecoder().decode(descriptiveJSON.self, from: data)
                podcastsItems = podcastDescriptions.results
                
                completion(podcastsItems)
            } catch {
                print(error)
            }
        }.resume()
        
       
    }

   
    
}
