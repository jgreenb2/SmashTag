//
//  HistoryTableViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/28/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

protocol HistoryDelegate: class {
    func getSearchHistory() -> [String]
    func clearSearchHistory()
    func startNewSearch(newSearchText:String)
    func deleteHistoryEntryAt(indexPath: NSIndexPath)
}

class HistoryTableViewController: UITableViewController {
    weak var delegate: HistoryDelegate?
    
    var searchHistory:[String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateHistory()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title="Recent Searches"
        tableView.scrollsToTop=true
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return searchHistory!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellIdentifier, forIndexPath: indexPath) as! HistoryTableViewCell

        // Configure the cell...
        cell.historyEntry.text = searchHistory![indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            delegate?.deleteHistoryEntryAt(indexPath)
            searchHistory = delegate?.getSearchHistory()
            tableView.reloadData()
        }
    }

    /* 
        This does not implement the recommendation in the homework -- it segues to
        a the search tab in the tabBarController because it just doesn't make sense to 
        stay in the same tab.

    */
    private struct TweetSegues {
        static let NewSearch = "goToNewSearch"
    }
    private struct Storyboard {
        static let TextCellIdentifier = "PreviousSearch"
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        if let identifier = segue.identifier {
            if let cell = sender as? HistoryTableViewCell {
                switch identifier {
                    case TweetSegues.NewSearch:
                        delegate?.startNewSearch(cell.historyEntry.text!)
                    default: break
                }
            }
        }
    }
    
    @IBAction func clearHistory() {
        
        let confirm = UIAlertController(title: "Confirm Clear", message: "Delete all items? This action cannot be undone.", preferredStyle: UIAlertControllerStyle.Alert)

        confirm.addAction(UIAlertAction(title: "Clear", style: UIAlertActionStyle.Destructive) {
            (action: UIAlertAction) -> Void in
                self.delegate?.clearSearchHistory()
                self.searchHistory = self.delegate?.getSearchHistory()
                self.tableView.reloadData()
        })
        confirm.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action: UIAlertAction) -> Void in
            return
        })
        presentViewController(confirm, animated: true, completion: nil)
    }
    
    func updateHistory() {
        searchHistory = delegate?.getSearchHistory()
    }
}
