//
//  AudioTable.swift
//  Tuneful
//
//  Created by Kevin Scott on 7/29/14.
//  Copyright (c) 2014 Kevin Scott. All rights reserved.
//

import Foundation
import UIKit

class AudioTable : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items : [Audio] = []
    var tableView: UITableView = UITableView()
    let cellHeight : CGFloat = 84
//    var tableView = UITableView()
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init() {
        super.init(nibName: nil, bundle: nil)
        items = []
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        self.items.append("yo")
//        //        var row = self.items.count-1
//        var indexPath = NSIndexPath(forRow:self.items.count-1,inSection:0)
//        println(indexPath)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
//        println("ok")

    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
//        println("count: \(self.items.count)")
//        return 1
        return self.items.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel.text = String(format: "%i", indexPath.row+1)
        
        let index = indexPath.row
//        println("table view, or return a cell")
        let audioView = self.items[index].image
        cell.textLabel.text = "something"
        cell.addSubview(audioView)
//        cell.textLabel.text =
//        cell.textLabel.text = "hi"
//        println(self.items)
        return cell
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return cellHeight;
    }
    
//    
//    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool
//    {
//        return true
//    }
//    
//    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!)
//    {
//        //        self.items.removeObjectAtIndex(indexPath.row)
//        
//        //        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
//        
//        
//    }
//    
//    func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle
//    {
//        return (UITableViewCellEditingStyle.Delete)
//    }
//    
//    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool
//    {
//        return true
//    }
//    
//    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!)
//    {
//        //        self.tableView?.moveRowAtIndexPath(sourceIndexPath, toIndexPath: destinationIndexPath)
//        //        self.items.exchangeObjectAtIndex(sourceIndexPath.row, withObjectAtIndex: destinationIndexPath.row)
//    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
//        println("row = %d",indexPath.row)
        var err : NSError? = nil
//        player = AVAudioPlayer(contentsOfURL: self.items[indexPath.row], error: &err)
//        
//        player!.delegate = self
//        player!.play()
        
    }

    func add(item: Audio) {
//        println("add")
//        let test = CGRect(x: 0,y: 0, width: self.view.frame.width, height: cellHeight)
        item.setFrame(CGRect(x: 0,y: 0, width: self.view.frame.width, height: cellHeight))
        self.items.append(item)
        var row = self.items.count-1
        var indexPath = NSIndexPath(forRow:row,inSection:0)

        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
}
