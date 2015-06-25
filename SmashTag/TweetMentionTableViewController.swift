//
//  TweetMentionTableViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/24/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class TweetMentionTableViewController: UITableViewController {
    private enum Mentions {
        case Users(String)
        case Urls(String)
        case Hashtags(String)
        case Images(Double, NSURL)
        
        var title: String {
            get {
                switch self {
                    case .Users(_): return "Users"
                    case .Urls(_): return "Urls"
                    case .Hashtags(_): return "Hashtags"
                    case .Images(_): return "Images"
                }
            }
        }
    }
    
    private var mentions = [String:[Mentions]]()
    
    private func addMention(mention m: Mentions) {
        if mentions[m.title] != nil {
            mentions[m.title]!.append(m)
        } else {
            mentions[m.title] = [m]
        }
    }
    
    var tweet: Tweet? {
        didSet {
            for url in tweet!.urls {
                addMention(mention: Mentions.Urls(url.description))
            }
            for hashtag in tweet!.hashtags {
                addMention(mention: Mentions.Hashtags(hashtag.description))
            }
            for user in tweet!.userMentions {
                addMention(mention: Mentions.Users(user.description))
            }
            for mediaItem in tweet!.media {
                addMention(mention: Mentions.Images(mediaItem.aspectRatio, mediaItem.url))
            }
        }
    }
    
    private struct MentionConfig {
        static let NumberOfMentionSections = 4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        //return MentionConfig.NumberOfMentionSections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    private struct Storyboard {
        static let CellResuseIdentifier = "Mentions"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellResuseIdentifier, forIndexPath: indexPath) as! MentionTableViewCell

        // Configure the cell by passing it the selected tweet
        cell.tweet = tweet
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
