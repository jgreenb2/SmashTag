//
//  HistoryTableViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/28/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    var searchHistory:[String]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return searchHistory!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TextCellIdentifier, forIndexPath: indexPath) as! HistoryTableViewCell

        // Configure the cell...
        cell.historyEntry.text = searchHistory![indexPath.row]
        return cell
    }


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
                    if let tbc = destination as? UITabBarController {
                        if let navCon = tbc.viewControllers?.first as? UINavigationController {
                            if let ttvc = navCon.visibleViewController as? TweetTableViewController {
                                if let cellID = cell.reuseIdentifier {
                                    if cellID == Storyboard.TextCellIdentifier {
                                        ttvc.searchText = cell.historyEntry.text
                                    }
                                }
                            }
                        }
                    }
                default: break
                }
            }
        }
    }

}
