//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/22/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate, UITabBarControllerDelegate {

    // our model is an array of an array of Tweets:
    var tweets = [[Tweet]]()
    static let defaultSearch = "#stanford"
    private var searchHistory:[String] = [ defaultSearch ]
    
    var searchText: String? = "#stanford" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
            updateHistory(searchText!)
        }
    }
    
    // MARK: - View Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
        tabBarController?.delegate = self
    }

    var lastSuccessfulRequest: TwitterRequest?
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
       refresh(refreshControl)
    }

    @IBAction func unwindToNewSearch(segue: UIStoryboardSegue) {
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections())), withRowAnimation: .None)
                        }
                        sender?.endRefreshing()
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return tweets[section].count
    }

    private struct Storyboard {
        static let CellResuseIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellResuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell

        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    /*  MARK: - Navigation
        when the users taps on a tweet we segue to a new table view that
        show the various mentions (user, url, hashtag, images)
    
        prepareForSegue passes the entire tweet to the new tableview controller
        since that's the easiest way to pass the mention data
    
    */
    @IBOutlet var tweetTableView: UITableView!
    private struct TweetTableSegues {
        static let MentionSegue = "ShowMentionTable"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let mentionTableViewController = destination as? TweetMentionTableViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case TweetTableSegues.MentionSegue:
                    if let row = tweetTableView.indexPathForSelectedRow()?.row {
                        let section = tweetTableView.indexPathForSelectedRow()!.section
                        mentionTableViewController.tweet = tweets[section][row]
                    }
                default: break
                }
            }
        }
    }

    private struct HistoryConfig {
        static let MaxEntries = 100
    }
    
    private func updateHistory(text:String) {
        if text != searchHistory.first {
            searchHistory.insert(text, atIndex: 0)
            if searchHistory.count > 100 {
                searchHistory.removeLast()
            }
        }
    }
        
   func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        println("tab controller change")
        if let hvc = viewController as? UINavigationController {
            if let htvc = hvc.visibleViewController as? HistoryTableViewController {
                htvc.searchHistory = self.searchHistory
            }
        }
    }
}
