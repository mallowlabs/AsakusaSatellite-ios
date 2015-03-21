//
//  RoomViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/21.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite


private let kCellID = "Cell"


class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let client: Client
    var room: Room
    var messages = [Message]()

    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    // MARK: - init
    
    init(client: Client, room: Room) {
        self.client = client
        self.room = room
        
        super.init(nibName: nil, bundle: nil)
        
        title = room.name
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = view.backgroundColor

        tableView.registerClass(TableCell.self, forCellReuseIdentifier: kCellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120 // requires at least minimum height for autolayout cells http://stackoverflow.com/questions/26100053/uitableviewcells-contentview-gets-unwanted-height-44-constraint
        tableView.separatorStyle = .None
        
        let autolayout = view.autolayoutFormat(["p": 8], [
            "table": tableView,
            ])
        autolayout("H:|[table]|")
        autolayout("V:|[table]|")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadMessages()
    }
    
    // MARK: -
    
    private func reloadMessages() {
        client.messageList(room.id, count: 20, sinceID: messages.last?.id, untilID: nil, order: .Desc) { r in
            switch r {
            case .Success(let many):
                let messages = many().items
                self.messages += messages.reverse()
                self.tableView.reloadData()
            case .Failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Cannot Load Messages", comment: ""), message: error?.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID, forIndexPath: indexPath) as TableCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    // MARK: - Custom Cell
    
    private class TableCell: UITableViewCell {
        let messageView = MessageView(frame: CGRectZero)
        var message: Message? {
            get {
                return messageView.message
            }
            set {
                messageView.message = newValue
            }
        }
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let autolayout = contentView.autolayoutFormat(nil, ["v": messageView])
            autolayout("H:|[v]|")
            autolayout("V:|[v]|")
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}