//
//  podcastCellView.swift
//  TestingDragDrop
//
//  Created by Osama Naeem on 19/01/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import UIKit
import Foundation

class PodcastCellView: UITableViewCell {
    
    let podcastName: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    let podcastImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.backgroundColor = .yellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(podcastName)
        addSubview(podcastImageView)
        setupViews()
    }
    
    func setupViews() {
        podcastImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        podcastImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        podcastImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        podcastImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        podcastName.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 12).isActive = true
        podcastName.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        podcastName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        podcastName.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
