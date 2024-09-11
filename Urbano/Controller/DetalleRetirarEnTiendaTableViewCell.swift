//
//  DetalleRetirarEnTiendaTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 30/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DetalleRetirarEnTiendaTableViewCell: UITableViewCell {

    @IBOutlet weak var boxDetalle: UIView!
    @IBOutlet weak var direccionLabel: UILabel!
    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var contactarConLabel: UILabel!
    @IBOutlet weak var fechaAproximadaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowWithRoundedCorners(view: boxDetalle)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func addShadowWithRoundedCorners(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 15)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 15
    }
    
    func setupDetalle(direccion: String, horario: String, telefono: String, contactarCon: String, fechaAproximada: String) {
        direccionLabel.text = direccion
        horarioLabel.text = horario
        telefonoLabel.text = telefono
        contactarConLabel.text = contactarCon
        fechaAproximadaLabel.text = fechaAproximada
    }

}
