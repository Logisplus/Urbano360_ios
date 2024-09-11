//
//  GalleryViewController.swift
//  Urbano
//
//  Created by Mick VE on 19/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView = UIImageView()
    
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        //images = [UIImage(named: "bg_home")!, UIImage(named: "img_entrega")!]
        images = [UIImage(named: "bg_home")!]
        
        for i in 0..<images.count {
            let x = self.view.frame.size.width * CGFloat(i)
            imageView.isUserInteractionEnabled = true
            imageView.frame = CGRect(x: x, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            imageView.contentMode = .scaleAspectFit
            imageView.image = images[i]
            
            self.scrollView.contentSize.width = scrollView.frame.size.width * CGFloat(i + 1)
            self.scrollView.addSubview(imageView)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

}
