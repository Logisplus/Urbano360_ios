//
//  IconInfoSeguimientoEnvioView.swift
//  Urbano
//
//  Created by Mick VE on 11/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class IconInfoSeguimientoEnvioView: UIView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        backgroundView.layer.cornerRadius = backgroundView.frame.size.width / 2
        backgroundView.clipsToBounds = true
        backgroundView.backgroundColor = RastrearEnvioViewController.PalleteColorUrbano.gris
    }
    
    class func instanceFromNib() -> IconInfoSeguimientoEnvioView {
        return UINib(nibName: "IconInfoSeguimientoEnvio", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! IconInfoSeguimientoEnvioView
    }
    
    func setupIconImage(nameImage: String) {
        iconImage.image = UIImage(named: nameImage)
        iconImage.image = iconImage.image!.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = UIColor.white
    }

}
