//
//  HistorialTransitoTableViewHeader.swift
//  Urbano
//
//  Created by Mick VE on 15/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class HistorialTransitoTableViewHeader: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var boxTitleView: UIView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> HistorialTransitoTableViewHeader {
        return UINib(nibName: "HistorialTransitoTableViewHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HistorialTransitoTableViewHeader
    }
    
    func nibSetup(title: String) {
        titleLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
        titleLabel.text = title
        boxTitleView.layer.cornerRadius = 5
        boxTitleView.clipsToBounds = true
    }

}
