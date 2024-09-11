//
//  AcercaDeTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 13/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class AcercaDeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameAppLabel: UILabel!
    @IBOutlet weak var versionAppLabel: UILabel!
    @IBOutlet weak var copyRightLabel: UILabel!
    @IBOutlet weak var copyRightBLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameAppLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
        versionAppLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.gris
        copyRightLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.gris
        copyRightBLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.gris
        
        versionAppLabel.text = "Versión \(getAppVersion())"
        //let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        //let build = Bundle.main.infoDictionary!["CFBundleVersion"]!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getAppVersion() -> String {
        return "\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")"
    }

}
