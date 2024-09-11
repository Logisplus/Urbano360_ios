//
//  MenuTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 12/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var boxIconView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        boxIconView.layer.cornerRadius = 6
        
        arrowImage.image = arrowImage.image!.withRenderingMode(.alwaysTemplate)
        arrowImage.tintColor = UIColor(red: CGFloat(199/255.0), green: CGFloat(199/255.0), blue: CGFloat(204/255.0), alpha: CGFloat(1.0))
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = boxIconView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        boxIconView.backgroundColor = color
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = boxIconView.backgroundColor
        super.setSelected(selected, animated: animated)
        boxIconView.backgroundColor = color
    }
    
    func setupMenu(menu: ConfiguracionTableViewController.Menu) {
        titleLabel.text = menu.title
        
        boxIconView.backgroundColor = menu.bgIcon
        
        iconImage.image = menu.icon
        iconImage.image = iconImage.image!.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = UIColor.white
    }

}
