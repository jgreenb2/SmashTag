//
//  MentionTableViewCell.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/24/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

// protocol to pass image data back to the ViewController
// since we've already loaded the data for the preview,
// there's no need to reload it if the user wants to view
// the entire image.
protocol ImageDataDelegate: class {
    func updateImageData(imageData: NSData)
}

class MentionTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var mentionView: UIImageView!
    @IBOutlet weak var urlView: UILabel!
    
    weak var delegate: ImageDataDelegate?
    var imageUrl = NSURL()
    
    var  mention: Mentions? {
        didSet {
            switch mention! {
                case .Images(let aspectRatio, let url):
                    fetchImage(aspectRatio, url)
                case .Users(let userName):
                    refreshTextCell(userName)
                case .Urls(let urlString):
                    refreshURLCell(urlString)
                case .Hashtags(let hashtagString):
                    refreshTextCell(hashtagString)
            }
        }
    }
    
    func fetchImage(aspectRatio: Double, _ url: NSURL) {
        let qos = Int(QOS_CLASS_USER_INITIATED.value) // legacy qos variable stuff
        imageUrl = url
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            let imageData = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if url == self.imageUrl {           // is captured url out of date?
                    if imageData != nil {
                        self.imageView?.sizeToFit()
                        self.mentionView.image = UIImage(data: imageData!)
                        self.delegate?.updateImageData(imageData!)
                    } else {
                        self.mentionView.image = nil
                    }
                }
            }
        }
    }

    func refreshTextCell(string: String) {
        textView.text = string
    }
 
    func refreshURLCell(string: String) {
        var attributes = [NSUnderlineStyleAttributeName:1, NSForegroundColorAttributeName: UIColor.blueColor()]
        var attributedString = NSAttributedString(string: string, attributes: attributes)
        urlView.attributedText = attributedString
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
