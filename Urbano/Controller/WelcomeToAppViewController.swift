//
//  WelcomeToAppViewController.swift
//  Urbano
//
//  Created by Mick VE on 16/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class WelcomeToAppViewController: UIViewController {

    @IBOutlet weak var lblTituloBienvenido: UILabel!
    @IBOutlet weak var continuarButton: UIButton!
    @IBOutlet weak var boxBGBienvenidaView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgColor = UIColor(red: CGFloat(235/255.0), green: CGFloat(235/255.0), blue: CGFloat(235/255.0), alpha: CGFloat(1.0))
        navigationController?.navigationBar.barTintColor = bgColor
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
        navigationController?.navigationBar.shadowImage = UIImage()
        boxBGBienvenidaView.backgroundColor = bgColor
        
        //lblTituloBienvenido.font = UIFont.systemFont(ofSize: 26.0, weight: .bold) // Note: Font size will be overridden
        //lblTituloBienvenido.fitTextToBounds()
        lblTituloBienvenido.numberOfLines = 1;
        lblTituloBienvenido.minimumScaleFactor = 0.5;
        lblTituloBienvenido.adjustsFontSizeToFitWidth = true;
        
        setupButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func continuarDidTouchUp(_ sender: Any) {
        performSegue(withIdentifier: "segueWelcomeToConfigPais", sender: nil)
    }
    
    func setupButton() {
        continuarButton.layer.cornerRadius = 8
        continuarButton.backgroundColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
    }

}
