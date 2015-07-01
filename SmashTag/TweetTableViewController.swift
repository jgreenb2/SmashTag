//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/22/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate, UITabBarControllerDelegate, HistoryDelegate {

    // our model is an array of an array of Tweets:
    var tweets = [[Tweet]]()
    private var defaultStore = NSUserDefaults.standardUserDefaults()

    var searchText: String? {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
            updateHistory(searchText)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveHistory()
    }
    
    // MARK: - View Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        refresh()
        htvc = setHistoryDelegate()
        tabBarController?.delegate = self
        restoreHistory()
        if searchText == nil {
            searchText = HistoryConfig.DefaultSearch
        }
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

    @IBAction func unwindToNewSearch(segue: UIStoryboardSegue) {}
        
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            // reloadSections tries to work around a known ios 8.1 bug where the
                            // disclosure caret accessory causes auto height to fail until the
                            // table is refreshed
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
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    private struct Storyboard {
        static let CellResuseIdentifier = "Tweet"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellResuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
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

    // MARK: - History Management
    // we've made this controller a delegate to the tabBarController so we're notified
    // when tabs change. When it does, we update the search history data.
    //
    private struct HistoryConfig {
        static let MaxEntries = 100
        static let DefaultSearch = "#stanford"
        static let KeyForHistoryArray = "searchHistory"
        static let ControllerTitle = "History NavCon"
        static let KeyForLastSearch = "lastSearchString"
    }
    
    private var searchHistory = [String]()
    private var htvc:HistoryTableViewController?

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if htvc != nil {
            htvc!.updateHistory()
        }
    }
    
    private func saveHistory() {
        defaultStore.setObject(searchHistory, forKey: HistoryConfig.KeyForHistoryArray)
        defaultStore.setValue(searchText, forKey: HistoryConfig.KeyForLastSearch)
    }
    
    private func restoreHistory() {
        if let history = defaultStore.stringArrayForKey(HistoryConfig.KeyForHistoryArray) as? [String] {
            searchHistory = history
        }
        searchText = defaultStore.stringForKey(HistoryConfig.KeyForLastSearch)
    }
    
    private func updateHistory(text:String?) {
        if let newText = text {
            let filtered = searchHistory.filter { $0 == text }
            if filtered.count == 0 {
                searchHistory.insert(newText, atIndex: 0)
                if searchHistory.count > 100 {
                    searchHistory.removeLast()
                }
            }
        }
    }

    func getSearchHistory() -> [String] {
        return searchHistory
    }
    
    func clearSearchHistory() {
        searchHistory.removeAll(keepCapacity: true)
        defaultStore.removeObjectForKey(HistoryConfig.KeyForLastSearch)
        defaultStore.removeObjectForKey(HistoryConfig.KeyForHistoryArray)
    }
    
    func startNewSearch(newSearchText: String) {
        searchText = newSearchText
        saveHistory()
    }
    
    // finds the History View Controller, sets this controller
    // as it's delegate and returns a ref to the history controller
    private func setHistoryDelegate() -> HistoryTableViewController? {
        if let vcs = tabBarController?.viewControllers {
            for vc in vcs {
                if vc.title == HistoryConfig.ControllerTitle {
                    if let htvc = vc.visibleViewController as? HistoryTableViewController {
                        htvc.delegate = self
                        return htvc
                    }
                }
            }
        }
        return nil
    }
}
