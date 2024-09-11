//
//  CalificarServicioHeaderView.swift
//  Urbano
//
//  Created by Mick VE on 2/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class CalificarServicioHeaderView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        titleLabel.textColor = ColorPalette.Urbano.negro
        descriptionLabel.textColor = ColorPalette.Urbano.negro
    }
    
    class func instanceFromNib() -> CalificarServicioHeaderView {
        return UINib(nibName: "CalificarServicioHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CalificarServicioHeaderView
    }

}
