//
//  UserMenuTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 19/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class UserMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = ColorPalette.Urbano.negro
        subTitleLabel.textColor = ColorPalette.Urbano.gris
        
        arrowImage.image = arrowImage.image!.withRenderingMode(.alwaysTemplate)
        arrowImage.tintColor = UIColor(red: CGFloat(199/255.0), green: CGFloat(199/255.0), blue: CGFloat(204/255.0), alpha: CGFloat(1.0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupMenu(menu: ConfiguracionTableViewController.Menu) {
        titleLabel.text = menu.title
        subTitleLabel.text = menu.subtitle
        
        iconImage.image = menu.icon
    }

}
