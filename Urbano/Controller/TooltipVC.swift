//
//  TooltipVC.swift
//  Urbano
//
//  Created by Mick VE on 2/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class TooltipVC: UIViewController {

    @IBOutlet weak var boxTextView: UIView!
    @IBOutlet weak var label: UILabel!
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
