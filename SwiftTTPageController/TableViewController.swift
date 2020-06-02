//
//  TableViewController.swift
//  SwiftTTPageController
//
//  Created by gener on 2018/8/8.
//  Copyright © 2018年 Light. All rights reserved.
//

import UIKit
import MobileCoreServices

class TableViewController: UITableViewController {
    
    var dataSource = [String]()
    
    let _colors:[UIColor] = [UIColor.red,
                             UIColor.blue,
                             UIColor.orange,
                             UIColor.cyan,
                             UIColor.yellow,
                             UIColor.green]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let i:Int = Int.init(arc4random()%6)
        
        view.backgroundColor = _colors[i]
        tableView.tableFooterView = UIView()
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        let count:Int = Int.init(arc4random()%9) + 1
        for num in (1...count) {
            dataSource.append(String(num-1))
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = String.init(format: "%lu - %@", indexPath.section, self.dataSource[indexPath.row])
        cell.accessibilityDragSourceDescriptors = [UIAccessibilityLocationDescriptor(name: "abc", view: cell)]
        cell.isAccessibilityElement = true
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("moveRowAt")
        let element = self.dataSource.remove(at: sourceIndexPath.row)
        self.dataSource.insert(element, at: destinationIndexPath.row)
    }
}

extension TableViewController: UITableViewDragDelegate {
    // MARK: - UITableViewDragDelegate
    
    /**
         The `tableView(_:itemsForBeginning:at:)` method is the essential method
         to implement for allowing dragging from a table.
    */
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        let placeName = placeNames[indexPath.row]

//        let data = placeName.data(using: .utf8)
        let data = self.dataSource[indexPath.row].data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }

        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }

    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        print("dragSessionDidEnd")
    }
}

extension TableViewController: UITableViewDropDelegate{

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
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
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // Consume drag items.
            let stringItems = items as! [String]

            var indexPaths = [IndexPath]()
            for (index, item) in stringItems.enumerated() {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                self.dataSource.insert(item, at: destinationIndexPath.row + index)
                indexPaths.append(indexPath)
            }

            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}
