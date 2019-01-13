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
    
    var itemsDroppedLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "0"
        return label
    }()
    var model = Model()
    var  itemDropped: Int = 0
    var cellid = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellid)
    
        view.addSubview(tableView)
        view.addSubview(circleView)
        view.bringSubviewToFront(circleView)
        circleView.addSubview(itemsDroppedLabel)
        customEnableDropping(on: circleView, dropInteractionDelegate: self as UIDropInteractionDelegate)
       
        
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
        
        itemsDroppedLabel.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 45).isActive = true
        itemsDroppedLabel.rightAnchor.constraint(equalTo: circleView.rightAnchor, constant: -45).isActive = true
        itemsDroppedLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        itemsDroppedLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.productName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellid)!
        cell.textLabel?.text = model.productName[indexPath.row]
        return cell
    }
    
    func customEnableDropping(on view: UIView, dropInteractionDelegate: UIDropInteractionDelegate) {
        let dropInteraction = UIDropInteraction(delegate: dropInteractionDelegate)
        view.addInteraction(dropInteraction)
    }
}

extension ViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        return model.dragItems(for: indexPath)
    }
    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return model.dragItems(for: indexPath)
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
        return model.canHandle(session)
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
                
                model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
                
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                    tableView.endUpdates()
                }
            } else {
            
            let itemProvider = item.dragItem.itemProvider
            itemProvider.loadObject(ofClass: NSString.self) { string, error in
                if let string = string as? String {
                    self.model.addItem(string, at: destinationIndexPath.row)
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
        return session.canLoadObjects(ofClass: NSString.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Consume drag items (in this example, of type NSString).
        
        session.loadObjects(ofClass: NSString.self) { string in
            let strings = string as! [NSString]
            for string in strings {
                print(string)
            }
           
            self.itemDropped = self.itemDropped + strings.count
            self.itemsDroppedLabel.text = "\(self.itemDropped)"
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


