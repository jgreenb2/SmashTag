//
//  TweetMentionTableViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/24/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

struct MentionConfig {
    // define section names
    struct Title {
        static let Urls = "Urls"
        static let Users = "Users"
        static let Hashtags = "Hashtags"
        static let Images = "Images"
    }
    // change the section ordering here
    static let SectionOrder:[String:Int]=[
        MentionConfig.Title.Images:0,
        MentionConfig.Title.Hashtags:1,
        MentionConfig.Title.Urls:2,
        MentionConfig.Title.Users:3
    ]
}

enum Mentions {
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
    
    var isImage: Bool {
        switch self {
            case .Images(_,_): return true
            default: return false
        }
    }
}


class TweetMentionTableViewController: UITableViewController {
    // MARK: - Table view data structures
    // the model for the Mention MVC is a refactored version of the
    // mention data contained in the referenced tweet
    
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
                addMention(mention: Mentions.Urls(url.keyword))
            }
            for hashtag in tweet!.hashtags {
                addMention(mention: Mentions.Hashtags(hashtag.keyword))
            }
            for user in tweet!.userMentions {
                addMention(mention: Mentions.Users(user.keyword))
            }
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // MARK: - Table view dataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return MentionConfig.SectionOrder.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].first?.title
    }

    private struct Storyboard {
        static let TextCellIdentifier = "TextMentions"
        static let ImageCellIdentifier = "ImageMentions"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:MentionTableViewCell
        var cellType:String
        
        let mention = mentions[indexPath.section][indexPath.row]
        if mention.isImage {
            cellType = Storyboard.ImageCellIdentifier
        } else {
            cellType = Storyboard.TextCellIdentifier
        }
        cell = tableView.dequeueReusableCellWithIdentifier(cellType, forIndexPath: indexPath) as! MentionTableViewCell
        
        // Configure the cell by passing it the selected tweet data
        cell.mention = mention
        
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentions[indexPath.section][indexPath.row]
        switch mention {
            case .Images(let aspectRatio, _):
                    return CGFloat(Double(view.frame.width) / aspectRatio)
            default:
                return UITableViewAutomaticDimension
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
