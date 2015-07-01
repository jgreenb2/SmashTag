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
        searchHistory = delegate?.getSearchHistory()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
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
        delegate?.clearSearchHistory()
        searchHistory = delegate?.getSearchHistory()
        tableView.reloadData()
    }
    
    func updateHistory() {
        searchHistory = delegate?.getSearchHistory()
    }
}
