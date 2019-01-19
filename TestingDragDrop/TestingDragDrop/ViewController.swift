//
//  ViewController.swift
//  TestingDragDrop
//
//  Created by Osama Naeem on 11/01/2019.
//  Copyright © 2019 NexThings. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.dragDelegate = self
        tv.dropDelegate = self
        tv.dragInteractionEnabled = true 
        return tv
    }()
    
    
    var circleView: UIView = {
       let circle = UIView()
        circle.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 70
        circle.clipsToBounds = true
        circle.isHidden = true
        return circle
    }()
    
  
    var model = Model()
    var podcastItems = [podcastModelData]()
    var  itemDropped: Int = 0
    var cellid = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchJSONData(searchQuery:"The Tech Guy")
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(PodcastCellView.self, forCellReuseIdentifier: cellid)
        title = "Podcasts"
        
        view.addSubview(tableView)
        view.addSubview(circleView)
        view.bringSubviewToFront(circleView)
        customEnableDropping(on: circleView, dropInteractionDelegate: self as UIDropInteractionDelegate)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Downloads", style: .plain, target: self, action: #selector(handleDetailedViewTapped))
        
        setupViews()
        
    }
    
    func setupViews() {
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        circleView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 15).isActive = true
        circleView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 15).isActive = true
        circleView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
 
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid, for: indexPath) as! PodcastCellView
        cell.podcastName.text = podcastItems[indexPath.row].collectionName
        if let podcastImageURL = podcastItems[indexPath.row].artworkUrl100 {
            cell.podcastImageView.loadImageFromURL(url:podcastImageURL)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124
    }
    func customEnableDropping(on view: UIView, dropInteractionDelegate: UIDropInteractionDelegate) {
        let dropInteraction = UIDropInteraction(delegate: dropInteractionDelegate)
        view.addInteraction(dropInteraction)
    }

    func fetchJSONData(searchQuery: String) {
        fetchJSON.getNetworkCall(searchQuery: searchQuery) { [weak self] (resultsArray: [podcastModelData]) in
            self?.podcastItems = resultsArray
            //print(self?.podcastItems)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc func handleDetailedViewTapped() {
        let destinationViewController = DetailedViewController()
        navigationController?.pushViewController(destinationViewController, animated: true)
        
    }
    
    
    
   
    
}



extension ViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
     
        let collectionName = podcastItems[indexPath.row].collectionName!
        let feedUrl = podcastItems[indexPath.row].feedUrl!
        let artworkurl = podcastItems[indexPath.row].artworkUrl100!
        
        let podcastItem = podcastModelData(collectionName: collectionName, feedURL: feedUrl, artworkURL100: artworkurl)
        
        let itemProvider = NSItemProvider(object: podcastItem)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        
        let collectionName = podcastItems[indexPath.row].collectionName!
        let feedUrl = podcastItems[indexPath.row].feedUrl!
        let artworkurl = podcastItems[indexPath.row].artworkUrl100!
        
        let podcastItem = podcastModelData(collectionName: collectionName, feedURL: feedUrl, artworkURL100: artworkurl)
        
        
        let itemProvider = NSItemProvider(object: podcastItem)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
   
    func tableView(_ tableView: UITableView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        circleView.isHidden = false
    }
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        //Add some sort of a delay here to show the number of items dragged before the view gets hidden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.circleView.isHidden = true
        }
        
    }
    
}

extension ViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: podcastModelData.self)
    }
    
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                
                
                guard sourceIndexPath != destinationIndexPath else { return }
                
                let podcastItem = podcastItems[sourceIndexPath.row]
                podcastItems.remove(at: sourceIndexPath.row)
                podcastItems.insert(podcastItem, at: destinationIndexPath.row)
                
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                    tableView.endUpdates()
                }
                
                print(podcastItem.collectionName)
                
            } else {
            
            let itemProvider = item.dragItem.itemProvider
            itemProvider.loadObject(ofClass: podcastModelData.self) { podcastItem, error in
                if let podcastItem = podcastItem as? podcastModelData {
                    self.podcastItems.insert(podcastItem, at: destinationIndexPath.row)
                  
                    DispatchQueue.main.async {
                        tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                    }
                }
                
            }
          }
        
        }
    }
    
   
}

extension ViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return  session.canLoadObjects(ofClass: podcastModelData.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        
        session.loadObjects(ofClass: podcastModelData.self) { (items) in
            if let podcasts = items as? [podcastModelData] {
                for item in podcasts {
                    print(item.collectionName)
                }
            }
        }
      
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        circleView.backgroundColor = .black
        
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        circleView.backgroundColor = .blue
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        circleView.backgroundColor = .blue
    }
    
}


extension UIImageView {
    
    func loadImageFromURL(url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: imageURL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                    
                }
            }
            
        }
        
    }
    
    
    
}




class DetailedViewController: UIViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = .red
    
       
    }
    
   
}

