//
//  ScrollableImageViewController.swift
//  SmashTag
//
//  Created by Jeff Greenberg on 6/27/15.
//  Copyright (c) 2015 Jeff Greenberg. All rights reserved.
//

import UIKit

class ScrollableImageViewController: UIViewController, UIScrollViewDelegate {

    var mustInitializeZoom = true
    
    var imageData:NSData? {
        didSet {
            imageView.image = UIImage(data: imageData!)
            scrollView?.contentSize = imageView.frame.size
            imageView.sizeToFit()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }

    private var imageView = UIImageView()
    
    func zoomToFit() {
        if mustInitializeZoom {
            let iw = imageView.image!.size.width
            let vw = scrollView!.superview!.frame.width
            scrollView.zoomScale = vw / iw
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        mustInitializeZoom = false
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        zoomToFit()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
