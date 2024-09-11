//
//  CentroNotificacionesTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 11/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class CentroNotificacionesTableViewCell: UITableViewCell {

    @IBOutlet weak var boxBGView: UIView!
    @IBOutlet weak var boxIconView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var descripcionLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        tituloLabel.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
        descripcionLabel.textColor = UIColor.lightGray
        fechaLabel.textColor = UIColor(red: CGFloat(24/255.0), green: CGFloat(123/255.0), blue: CGFloat(207/255.0), alpha: CGFloat(1.0))
        
        boxIconView.layer.cornerRadius = boxIconView.frame.size.width / 2
        boxIconView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupNotificacion(notificacion: FetchCentroNotificacionesResponse.Notificacion) {
        tituloLabel.text = notificacion.titulo
        descripcionLabel.text = notificacion.notificacion
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = dateFormatter.date(from: notificacion.fecha_notificacion) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "dd MMM"
            let fecha = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "h:mm a"
            let hora = newDateFormatter.string(from: date)
            fechaLabel.text = "\(fecha) a las \(hora)"
        } else {
            fechaLabel.text = notificacion.fecha_notificacion
        }
        
        if let idNotificacion = Int(notificacion.id_notify) {
            switch idNotificacion {
                case 1:
                    setupIconImage(nameImage: "ic_package_35pt")
                case 2:
                    setupIconImage(nameImage: "ic_package_airplane_takeoff_35pt")
                case 3:
                    setupIconImage(nameImage: "ic_package_airplane_landing_35pt")
                case 4:
                    setupIconImage(nameImage: "ic_truck_35pt")
                case 5:
                    setupIconImage(nameImage: "ic_package_like_35pt")
                case 6:
                    setupIconImage(nameImage: "ic_package_dislike_35pt")
                case 7:
                    setupIconImage(nameImage: "ic_truck_delivery_35pt")
                default:
                    iconImage.image = UIImage(named: "ic_package_seguimiento_envio")
            }
            
            switch idNotificacion {
            case 5:
                boxIconView.backgroundColor = UIColor(red: CGFloat(24/255.0), green: CGFloat(155/255.0), blue: CGFloat(72/255.0), alpha: CGFloat(1.0))
            case 6:
                boxIconView.backgroundColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
            default:
                boxIconView.backgroundColor = RastrearEnvioViewController.PalleteColorUrbano.negro
            }
        } else {
            iconImage.image = UIImage(named: "ic_package_seguimiento_envio")
            boxIconView.backgroundColor = RastrearEnvioViewController.PalleteColorUrbano.gris
        }
        
        if let totalVista = Int(notificacion.n_veces), totalVista == 0 {
            boxBGView.backgroundColor = UIColor(red: CGFloat(24/255.0), green: CGFloat(123/255.0), blue: CGFloat(207/255.0), alpha: CGFloat(0.2))
        } else {
            boxBGView.backgroundColor = UIColor.white
        }
        
        /*for subview in iconsEstadoGuiaStackView.arrangedSubviews {
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
        }*/
    }
    
    func setupIconImage(nameImage: String) {
        iconImage.image = UIImage(named: nameImage)
        iconImage.image = iconImage.image!.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = UIColor.white
    }

}
