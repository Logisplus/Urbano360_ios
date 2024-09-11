//
//  DetalleReprogramacionVisitaTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 30/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MapKit

class DetalleReprogramacionVisitaTableViewCell: UITableViewCell {

    @IBOutlet weak var boxContent: UIView!
    @IBOutlet weak var direccionLabel: UILabel!
    @IBOutlet weak var tipoServicioLabel: UILabel!
    @IBOutlet weak var fechaLabel: UILabel!
    @IBOutlet weak var horarioLabel: UILabel!
    @IBOutlet weak var nombreAutorizadoLabel: UILabel!
    @IBOutlet weak var dniAutorizadoLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var boxNombreAutorizadoView: UIView!
    @IBOutlet weak var boxDniAutorizadoView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgQRCode: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadowWithRoundedCorners(view: boxContent)
        
        mapView.delegate = self
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
    
    func setupDetalle(guiaElectronica: String, detalleReprogramacion: FetchDetalleReprogramacionVisitaResponse.DetalleReprogramacion) {
        imgQRCode.image = generateQRCode(from: guiaElectronica)
        
        direccionLabel.text = detalleReprogramacion.direccion.capitalized
        tipoServicioLabel.text = detalleReprogramacion.tipo_servicio
        fechaLabel.text = formatFecha(fecha: detalleReprogramacion.fecha_programada)
        horarioLabel.text = detalleReprogramacion.hora_programada
        nombreAutorizadoLabel.text = detalleReprogramacion.nombre_autorizado
        dniAutorizadoLabel.text = detalleReprogramacion.dni_autorizado
        
        if detalleReprogramacion.nombre_autorizado.isEmpty {
            stackView.removeArrangedSubview(boxNombreAutorizadoView)
            boxNombreAutorizadoView.removeFromSuperview()
        }
        
        if detalleReprogramacion.dni_autorizado.isEmpty {
            stackView.removeArrangedSubview(boxDniAutorizadoView)
            boxDniAutorizadoView.removeFromSuperview()
        }
        
        if let x = Double(detalleReprogramacion.px), let y = Double(detalleReprogramacion.py), (x != 0 && y != 0) {
            let location = CLLocationCoordinate2DMake(x, y)
            let pin = PinAnnotation(title: "", subtitle: "", coordinate: location)
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(location, 1000, 1000), animated: true)
            mapView.addAnnotation(pin)
        }
    }
    
    func formatFecha(fecha: String) -> String {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatter.date(from: fecha) {
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "EEEE"
            let dayName = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "MMMM"
            let monthName = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: date)
            return "\(dayName.capitalized), \(day) de \(monthName.capitalized) del \(year)"
        } else {
            return "Fecha no valida."
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}

extension DetalleReprogramacionVisitaTableViewCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if anView == nil {
            anView?.annotation = annotation
        } else {
            if let _ = annotation as? PinAnnotation {
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                pinView.pinTintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
                anView = pinView
            }
        }
        
        return anView
    }
    
}
