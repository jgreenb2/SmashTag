//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/22/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Tweet? {
        didSet {
            UpdateUI()
        }
    }
    
    func UpdateUI() {
        // reset existing tweet info
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        //tweetCreatedLabel?.text = nil
        
        // load new information from tweet (if any)
        if let tweet = self.tweet {
            let highlightedTweetText = highlightTweetText(tweet)
            tweetTextLabel?.attributedText = highlightedTweetText
            if tweetTextLabel?.attributedText != nil {
                for _ in tweet.media {
                    tweetTextLabel.attributedText! = tweetTextLabel.attributedText! +   " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)"
            
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL) {
                    // blocks main thread -- must fix!
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
        }
    }
    private struct HighlightColors {
        static let urlColor = UIColor.blueColor()
        static let userColor = UIColor.orangeColor()
        static let hashColor = UIColor.redColor()
    }
    
    func highlightTweetText(tweet: Tweet) -> NSAttributedString {
        
        var highlightedString = NSMutableAttributedString(string: tweet.text)
        
        for hash in tweet.hashtags {
            highlightedString.addAttribute(NSForegroundColorAttributeName, value: HighlightColors.hashColor, range: hash.nsrange)
        }
        for user in tweet.userMentions {
            highlightedString.addAttribute(NSForegroundColorAttributeName, value: HighlightColors.userColor, range: user.nsrange)
        }
        for url in tweet.urls {
            highlightedString.addAttribute(NSForegroundColorAttributeName, value: HighlightColors.urlColor, range: url.nsrange)
        }
        
        return highlightedString
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

    
}

private func + (s1: NSAttributedString, s2: String) -> NSAttributedString {
    var newAStr = NSMutableAttributedString(attributedString: s1)
    newAStr.appendAttributedString(NSAttributedString(string: s2))
    return newAStr
}

private func + (s1: String, s2: NSAttributedString) -> NSAttributedString {
    var newAStr = NSMutableAttributedString(string: s1)
    newAStr.appendAttributedString(s2)
    return newAStr
}

private func + (s1: NSAttributedString, s2: NSAttributedString) -> NSMutableAttributedString {
    var newAStr = NSMutableAttributedString(attributedString: s1)
    newAStr.appendAttributedString(s2)
    return newAStr
}

