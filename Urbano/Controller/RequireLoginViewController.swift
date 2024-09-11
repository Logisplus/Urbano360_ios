//
//  RequireLoginViewController.swift
//  Urbano
//
//  Created by Mick VE on 4/09/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class RequireLoginViewController: UIViewController {
    
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var iniciarSesionButton: UIButton!
    
    var delegate: RequireLoginDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tituloLabel.textColor = ColorPalette.Urbano.negro
        descripcionLabel.textColor = ColorPalette.Urbano.gris
        iniciarSesionButton.layer.cornerRadius = 8
        //iniciarSesionButton.clipsToBounds = true
        iniciarSesionButton.backgroundColor = ColorPalette.Urbano.rojo
        
        self.navigationItem.largeTitleDisplayMode = .never
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func iniciarSesionDidTap(_ sender: Any) {
        delegate?.iniciarSesionDidTap()
    }
    
    func setupView(navTitle: String, descripcion: String, imagen: UIImage) {
        self.navigationItem.title = navTitle
        descripcionLabel.text = descripcion
        imageView.image = imagen
    }

}
