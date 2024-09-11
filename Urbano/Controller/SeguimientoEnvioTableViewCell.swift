//
//  SeguimientoEnvioTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 9/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class SeguimientoEnvioTableViewCell: UITableViewCell {

    @IBOutlet weak var boxBGView: UIView!
    @IBOutlet weak var iconsEstadoGuiaStackView: UIStackView!
    @IBOutlet weak var guiaLabel: UILabel!
    @IBOutlet weak var estadoGuiaLabel: UILabel!
    @IBOutlet weak var descripcionEstadoGuiaLabel: UILabel!
    @IBOutlet weak var fechaEstadoGuiaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCellStyle(style: SeguimientoEnvioTableViewCellStyle, bgColor: UIColor) {
        switch style {
        case .default:
            guiaLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
            estadoGuiaLabel.textColor = UIColor.lightGray
            descripcionEstadoGuiaLabel.textColor = UIColor.lightGray
            fechaEstadoGuiaLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
            boxBGView.backgroundColor = UIColor.white
        case .color:
            guiaLabel.textColor = UIColor.white
            estadoGuiaLabel.textColor = UIColor.white
            descripcionEstadoGuiaLabel.textColor = UIColor.white
            fechaEstadoGuiaLabel.textColor = UIColor.white
            boxBGView.backgroundColor = bgColor
        }
    }
    
    func setupEnvio(envio: FetchEnviosEnSeguimientoResponse.Envio) {
        guiaLabel.text = envio.barra
        estadoGuiaLabel.text = envio.estado
        descripcionEstadoGuiaLabel.text = envio.detalle.replacingOccurrences(of: "<br>", with: "\n")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatter.date(from: envio.fecha) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "dd MMM"
            let fecha = newDateFormatter.string(from: date)
            fechaEstadoGuiaLabel.text = fecha
        } else {
            fechaEstadoGuiaLabel.text = envio.fecha
        }
        
        for subview in iconsEstadoGuiaStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        if let estadoNotificacion = Int(envio.notify), estadoNotificacion == 1 {
            let iconView = IconInfoSeguimientoEnvioView.instanceFromNib()
            iconView.setupIconImage(nameImage: "ic_bell_v2_25pt")
            
            iconsEstadoGuiaStackView.insertArrangedSubview(iconView, at: 0)
        }
        
        if let estadoAgendamiento = Int(envio.pend_agendamiento), estadoAgendamiento == 1 {
            let iconView = IconInfoSeguimientoEnvioView.instanceFromNib()
            iconView.setupIconImage(nameImage: "ic_calendar_25pt")
            
            let index = (iconsEstadoGuiaStackView.arrangedSubviews.count == 1) ? 1 : 0
            iconsEstadoGuiaStackView.insertArrangedSubview(iconView, at: index)
        }
    }

}

enum SeguimientoEnvioTableViewCellStyle: Int {
    case `default`
    
    case color
}
