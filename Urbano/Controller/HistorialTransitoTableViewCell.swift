//
//  HistorialTransitoTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 14/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class HistorialTransitoTableViewCell: UITableViewCell {

    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var detalleLabel: UILabel!
    @IBOutlet weak var horaLabel: UILabel!
    @IBOutlet weak var ampmLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var lineTimeLineView: UIView!
    @IBOutlet weak var boxBGView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func cellStyleSetup(style: HistorialTransitoTableViewCellStyle, bgColor: UIColor?, hiddenArrow: Bool, hiddenLine: Bool) {
        switch style {
        case .default:
            tituloLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
            detalleLabel.textColor = UIColor.lightGray
            horaLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
            ampmLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
            boxBGView.backgroundColor = UIColor.white
        case .color:
            tituloLabel.textColor = UIColor.white
            detalleLabel.textColor = UIColor.white
            horaLabel.textColor = UIColor.white
            ampmLabel.textColor = UIColor.white
            boxBGView.backgroundColor = bgColor
        }
        arrowImage.isHidden = hiddenArrow
        lineTimeLineView.isHidden = hiddenLine
    }
    
    enum HistorialTransitoTableViewCellStyle : Int {
        case `default`
        
        case color
    }

}
