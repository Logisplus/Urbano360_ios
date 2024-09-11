//
//  DetalleCourierController.swift
//  Urbano
//
//  Created by Mick VE on 4/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DetalleCourierController: PullUpController {

    @IBOutlet weak var courierBoxContainerView: UIView!
    @IBOutlet weak var direccionBoxContainerView: UIView!
    @IBOutlet weak var placaBoxContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var nombreCourierLabel: UILabel!
    @IBOutlet weak var descripcionRutaLabel: UILabel!
    @IBOutlet weak var placaLabel: UILabel!
    @IBOutlet weak var direccionEntregaLabel: UILabel!
    @IBOutlet weak var unidadImage: UIImageView!
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.layer.cornerRadius = separatorView.frame.height / 2
        }
    }
    
    var eTracking: FetchEnvioResponse.Data.ETracking?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.mask = roundCorners([.topLeft, .topRight], radius: 10)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: view.layer.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        return mask
    }
    
    // MARK: - PullUpController
    
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: direccionBoxContainerView.frame.maxY)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return courierBoxContainerView.frame.height
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [middleView.frame.maxY]
    }
    
    override var pullUpControllerIsBouncingEnabled: Bool {
        return false
    }
    
    override var pullUpControllerPreferredLandscapeFrame: CGRect {
        return CGRect(x: 5, y: 5, width: 280, height: UIScreen.main.bounds.height - 10)
    }
    
    func setupView() {
        placaBoxContainerView.layer.cornerRadius = 5
        placaBoxContainerView.layer.borderColor = ColorPalette.Urbano.negro.cgColor
        placaBoxContainerView.layer.borderWidth = 1
        nombreCourierLabel.textColor = ColorPalette.Urbano.negro
        direccionEntregaLabel.textColor = ColorPalette.Urbano.negro
        placaLabel.textColor = ColorPalette.Urbano.negro
        
        nombreCourierLabel.text = eTracking!.nom_courier
        placaLabel.text = eTracking!.und_placa
        
        if let tipoUnidad = Int(eTracking!.tipo_unidad) {
            if tipoUnidad == 1 {
                unidadImage.image = UIImage(named: "ic_walk_35pt")
            } else if tipoUnidad == 2 {
                unidadImage.image = UIImage(named: "ic_motorbike_35pt")
            } else if tipoUnidad == 3 {
                unidadImage.image = UIImage(named: "ic_truck_35pt")
            }
        }
        
        if let guiasEntregaPendiente = Int(eTracking!.ge_faltante), guiasEntregaPendiente > 2 {
            descripcionRutaLabel.text = "Tenemos \(guiasEntregaPendiente) entrega(s) previa a la tuya."
            
        } else {
            //descripcionRutaLabel.text = "Llegamos en %tiempo aprox."
            descripcionRutaLabel.text = ""
        }
        
        if eTracking!.referencia.isEmpty {
            self.direccionEntregaLabel.text = "\(eTracking!.direccion) - \(eTracking!.localidad)"
        } else {
            self.direccionEntregaLabel.text = "\(eTracking!.direccion) - Ref. \(eTracking!.referencia) - \(eTracking!.localidad)"
        }
    }
    
    func setTextDescripcionRuta(text: String) {
        descripcionRutaLabel.text = text
    }

}
