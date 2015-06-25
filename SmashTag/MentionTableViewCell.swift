//
//  MentionTableViewCell.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/24/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class MentionTableViewCell: UITableViewCell {
    @IBOutlet weak var debugContent: UILabel!
    var tweet: Tweet? {
        didSet {
            debugContent.text=tweet?.description
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
