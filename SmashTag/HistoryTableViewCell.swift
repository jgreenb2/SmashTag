//
//  HistoryTableViewCell.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/29/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var historyEntry: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
