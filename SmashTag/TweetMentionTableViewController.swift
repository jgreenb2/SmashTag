//
//  TweetMentionTableViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/24/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

private struct MentionConfig {
    struct Title {
        static let Urls = "Urls"
        static let Users = "Users"
        static let Hashtags = "Hashtags"
        static let Images = "Images"
    }
    static let SectionOrder:[String:Int]=[
        MentionConfig.Title.Images:0,
        MentionConfig.Title.Hashtags:1,
        MentionConfig.Title.Urls:2,
        MentionConfig.Title.Users:3
    ]
}

class TweetMentionTableViewController: UITableViewController {
    private enum Mentions {
        case Users(String)
        case Urls(String)
        case Hashtags(String)
        case Images(Double, NSURL)
        
        var title: String {
            get {
                switch self {
                    case .Users(_): return MentionConfig.Title.Users
                    case .Urls(_): return MentionConfig.Title.Urls
                    case .Hashtags(_): return MentionConfig.Title.Hashtags
                    case .Images(_): return MentionConfig.Title.Images
                }
            }
        }
    }
    
    private var mentions = [[Mentions]](count: MentionConfig.SectionOrder.count,
                                        repeatedValue: [Mentions]())
    
    private func addMention(mention m: Mentions) {
        if let i = MentionConfig.SectionOrder[m.title] {
            mentions[i] += [m]
        }
    }
    
    var tweet: Tweet? {
        didSet {
            for mediaItem in tweet!.media {
                addMention(mention: Mentions.Images(mediaItem.aspectRatio, mediaItem.url))
            }
            for url in tweet!.urls {
                addMention(mention: Mentions.Urls(url.description))
            }
            for hashtag in tweet!.hashtags {
                addMention(mention: Mentions.Hashtags(hashtag.description))
            }
            for user in tweet!.userMentions {
                addMention(mention: Mentions.Users(user.description))
            }
        }
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
