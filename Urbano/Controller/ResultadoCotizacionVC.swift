//
//  ResultadoCotizacionVC.swift
//  Urbano
//
//  Created by Mick VE on 21/09/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class ResultadoCotizacionVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var boxBorderOrigenView: UIView!
    @IBOutlet weak var boxBorderDestinoView: UIView!
    
    @IBOutlet weak var origenButton: UIButton!
    @IBOutlet weak var destinoButton: UIButton!
    
    @IBOutlet weak var boxResultadoCotizacionView: UIView!
    @IBOutlet weak var boxCotizacionTerrestreView: UIView!
    @IBOutlet weak var boxCotizacionAereaView: UIView!
    
    @IBOutlet weak var tipoProductoTerrestreImageView: UIImageView!
    @IBOutlet weak var tipoProductoAereoImageView: UIImageView!
    
    @IBOutlet weak var tipoProductoTerrestreLabel: UILabel!
    @IBOutlet weak var tipoProductoAereoLabel: UILabel!
    
    @IBOutlet weak var tiempoEnvioTerrestreLabel: UILabel!
    @IBOutlet weak var tiempoEnvioAereoLabel: UILabel!
    
    @IBOutlet weak var costoTerrestreLabel: UILabel!
    @IBOutlet weak var costoAereoLabel: UILabel!
    
    var ciudadOrigen: FetchDistritosPorDepartamentoResponse.Distrito?
    var ciudadDestino: FetchDistritosPorDepartamentoResponse.Distrito?
    
    var resultadoCotizacion: FetchCotizarEnvioResponse.ResultadoCotizacion?
    
    var tipoProductoSelected = 0
    var asegurarEnvioSelected = false
    
    var pesoPaquete = ""
    var anchoPaquete = ""
    var altoPaquete = ""
    var largoPaquete = ""
    var valorDeclarado = ""
    var simboloMoneda = ""
    
    var costoTerrestre = 0.0
    var costoAereo = 0.0
    
    var coordinateCiudadOrigen: CLLocationCoordinate2D?
    var coordinateCiudadDestino: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    @IBAction func origenButtonDidTap(_ sender: Any) {
        if coordinateCiudadOrigen != nil {
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinateCiudadOrigen!, 3500, 3500), animated: true)
        }
    }
    
    @IBAction func destinoButtonDidTap(_ sender: Any) {
        if coordinateCiudadDestino != nil {
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinateCiudadDestino!, 3500, 3500), animated: true)
        }
    }
    
    @IBAction func infoCostoTerrestreButtonDidTap(_ sender: Any) {
        showAlertInfoCostoEstimado()
    }
    
    @IBAction func infoCostoAereoButtonDidTap(_ sender: Any) {
        showAlertInfoCostoEstimado()
    }
    
    @objc func enviarCotizacionButtonDidTap() {
        sendEmailCotizacion()
    }
    
    func setupViews() {
        var buttons: [UIBarButtonItem] = []
        buttons.append(UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.enviarCotizacionButtonDidTap)))
        self.navigationItem.rightBarButtonItems = buttons
        
        addBorderBoxInput(view: boxBorderOrigenView)
        addBorderBoxInput(view: boxBorderDestinoView)
        
        origenButton.setTitle("\(ciudadOrigen!.distrito.capitalized), \(ciudadOrigen!.provincia.capitalized), \(ciudadOrigen!.departamento.capitalized)", for: .normal)
        destinoButton.setTitle("\(ciudadDestino!.distrito.capitalized), \(ciudadDestino!.provincia.capitalized), \(ciudadDestino!.departamento.capitalized)", for: .normal)
        
        if tipoProductoSelected == 0 {
            tipoProductoTerrestreImageView.image = UIImage(named: "ic_package_white_25pt")
            tipoProductoTerrestreLabel.text = "Paquetes"
            tipoProductoAereoImageView.image = UIImage(named: "ic_package_white_25pt")
            tipoProductoAereoLabel.text = "Paquetes"
        } else {
            tipoProductoTerrestreImageView.image = UIImage(named: "ic_files_white_25pt")
            tipoProductoTerrestreLabel.text = "Sobres"
            tipoProductoAereoImageView.image = UIImage(named: "ic_files_white_25pt")
            tipoProductoAereoLabel.text = "Sobres"
        }
        
        boxResultadoCotizacionView.backgroundColor = ColorPalette.Urbano.rojo
        boxCotizacionTerrestreView.backgroundColor = ColorPalette.Urbano.rojo
        boxCotizacionAereaView.backgroundColor = ColorPalette.Urbano.rojo
        
        setBackgroundRedSubViews(boxCotizacionTerrestreView)
        setBackgroundRedSubViews(boxCotizacionAereaView)
        
        setupMapView()
        
        setupPinsMapView()
        
        setupDatosCotizacion()
    }
    
    func setBackgroundRedSubViews(_ mainView: UIView) {
        for i in 0...2 {
            mainView.subviews[0].subviews[1].subviews[i].backgroundColor = ColorPalette.Urbano.rojo
        }
    }
    
    func addBorderBoxInput(view: UIView) {
        view.layer.cornerRadius = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
    }
    
    func setupMapView() {
        mapView.mapType = .standard
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
    }
    
    func setupDatosCotizacion() {
        switch UserDefaultsManager.shared.country! {
        case .Chile, .Ecuador:
            simboloMoneda = "$"
        case .Peru:
            simboloMoneda = "S/"
        }
        
        costoTerrestre = Double(resultadoCotizacion!.valor_ennvio)!
        costoAereo = Double(resultadoCotizacion!.valor_envio_aereo)!
        
        if costoTerrestre == 0.0 && costoAereo == 0.0 {
            costoTerrestreLabel.text = "\(simboloMoneda) 0"
            boxCotizacionAereaView.isHidden = true
            
            showAlertInfoNoHayCostoEstimado()
        } else {
            if costoTerrestre > 0.0 {
                tiempoEnvioTerrestreLabel.text = formatTiempoEnvio(tiempo: resultadoCotizacion!.time_envio)
                switch UserDefaultsManager.shared.country! {
                case .Chile:
                    costoTerrestreLabel.text = "\(simboloMoneda) \(Int(round(costoTerrestre)))"
                default:
                    costoTerrestreLabel.text = "\(simboloMoneda) \(costoTerrestre)"
                }
            } else {
                boxCotizacionTerrestreView.isHidden = true
            }
            
            if costoAereo > 0.0 {
                tiempoEnvioAereoLabel.text = formatTiempoEnvio(tiempo: resultadoCotizacion!.time_aereo)
                switch UserDefaultsManager.shared.country! {
                case .Chile:
                    costoAereoLabel.text = "\(simboloMoneda) \(Int(round(costoAereo)))"
                default:
                    costoAereoLabel.text = "\(simboloMoneda) \(costoAereo)"
                }
            } else {
                boxCotizacionAereaView.isHidden = true
            }
        }
    }
    
    func setupPinsMapView() {
        if let x = Double(ciudadOrigen!.ciu_px), let y = Double(ciudadOrigen!.ciu_py), (x != 0 && y != 0) {
            coordinateCiudadOrigen = CLLocationCoordinate2D(latitude: x, longitude: y)
            let pin = PinCiudadAnnotation(title: ciudadOrigen!.distrito, subtitle: "", tipoCiudad: "origen", coordinate: coordinateCiudadOrigen!)
            self.mapView.addAnnotation(pin)
        }
        
        if let x = Double(ciudadDestino!.ciu_px), let y = Double(ciudadDestino!.ciu_py), (x != 0 && y != 0) {
            coordinateCiudadDestino = CLLocationCoordinate2D(latitude: x, longitude: y)
            let pin = PinCiudadAnnotation(title: ciudadDestino!.distrito, subtitle: "", tipoCiudad: "destino", coordinate: coordinateCiudadDestino!)
            self.mapView.addAnnotation(pin)
        }
        
        if coordinateCiudadOrigen != nil && coordinateCiudadDestino != nil {
            self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(coordinateCiudadDestino!, 3500, 3500), animated: true)
        }
    }
    
    func formatTiempoEnvio(tiempo: String) -> String {
        var partTiempo = tiempo.split(separator: " ")
        let dia = Int(partTiempo[0])!
        
        partTiempo = partTiempo[1].split(separator: ":")
    
        let hora = Int(partTiempo[0])!
        let minuto = Int(partTiempo[1])!
        
        var formatTiempoEnvio = ""
        
        if dia != 0 {
            formatTiempoEnvio += "\(dia) día(s) "
        }
        
        if hora != 0 {
            formatTiempoEnvio += "\(hora) h "
        }
        
        if minuto != 0 {
            formatTiempoEnvio += "\(minuto) min "
        }
        
        if !formatTiempoEnvio.isEmpty {
            return "\(formatTiempoEnvio) aprox."
        } else {
            return "Tiempo no disponible."
        }
    }
    
    func showAlertInfoCostoEstimado() {
        if costoTerrestre > 0.0 || costoAereo > 0.0 {
            let message = asegurarEnvioSelected ? "Ten en cuenta que la cotización es un costo estimado (incluye el valor asegurado) y el costo real puede variar."
                : "Ten en cuenta que la cotización es un costo estimado y el costo real puede variar."
            let alertController = UIAlertController(title: nil,
                                                    message: message,
                                                    preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                
            }
            
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        } else {
            showAlertInfoNoHayCostoEstimado()
        }
    }
    
    func showAlertInfoNoHayCostoEstimado() {
        let alertController = UIAlertController(title: nil,
                                                message: "Lo sentimos, por el momento no tenemos un precio disponible para esta cotización.",
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
            
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendEmailCotizacion() {
        if MFMailComposeViewController.canSendMail() {
            var correo = ""
            switch UserDefaultsManager.shared.country! {
            case .Chile:
                correo = "customer.service@urbanoexpress.cl"
            case .Ecuador:
                correo = "comercial@urbano.com.ec"
            case .Peru:
                correo = "comercial@urbano.com.pe"
            }
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([correo])
            mail.setSubject("Cotización de envío")
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            mail.setMessageBody(buildBodyEmailCotizacion(), isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func buildBodyEmailCotizacion() -> String {
        var body = "<p><b>Cotización de envío</b></p>"
        
        body += "<p><b>Origen:</b> \(ciudadOrigen!.distrito.capitalized), \(ciudadOrigen!.provincia.capitalized), \(ciudadOrigen!.departamento.capitalized)<br>"
        body += "<b>Destino:</b> \(ciudadDestino!.distrito.capitalized), \(ciudadDestino!.provincia.capitalized), \(ciudadDestino!.departamento.capitalized)</p>"
        
        body += "<p><b>Tipo de producto:</b> \(tipoProductoSelected == 0 ? "Paquetes" : "Sobres")<br>"
        
        if asegurarEnvioSelected {
            body += "<b>Valor asegurado:</b> \(simboloMoneda) \(valorDeclarado)<br>"
        }
        
        if tipoProductoSelected == 0 {
            body += "<b>Peso del producto:</b> \(pesoPaquete)<br>"
            body += "<b>Medidas del producto:</b> \(anchoPaquete) (ancho), \(altoPaquete) (alto), \(largoPaquete) (largo)</p>"
        }
        
        if !asegurarEnvioSelected && tipoProductoSelected == 1 {
            body += "</p>"
        }
        
        if costoTerrestre > 0 {
            body += "<p><b>Tipo de envío: Terrestre</b><br>"
            body += "<b>Tiempo de envío:</b> \(formatTiempoEnvio(tiempo: resultadoCotizacion!.time_envio))<br>"
            switch UserDefaultsManager.shared.country! {
            case .Chile:
                body += "<b>Precio aprox.:</b> \(simboloMoneda) \(Int(round(costoTerrestre)))</p>"
            default:
                body += "<b>Precio aprox.:</b> \(simboloMoneda) \(costoTerrestre)</p>"
            }
        }
        
        if costoAereo > 0 {
            body += "<p><b>Tipo de envío: Aéreo</b><br>"
            body += "<b>empo de envío:</b> \(formatTiempoEnvio(tiempo: resultadoCotizacion!.time_aereo))<br>"
            switch UserDefaultsManager.shared.country! {
            case .Chile:
                body += "<b>Precio aprox.:</b> \(simboloMoneda) \(Int(round(costoAereo)))</p>"
            default:
                body += "<b>Precio aprox.:</b> \(simboloMoneda) \(costoAereo)</p>"
            }
        }
        
        return body
    }

}

// MARK: MKView Delegate

extension ResultadoCotizacionVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        if view != nil {
            if let pinAnnotation = annotation as? PinCiudadAnnotation {
                
                if pinAnnotation.tipoCiudad == "origen" {
                    let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pinOrigen")
                    pinView.markerTintColor = ColorPalette.Urbano.negro
                    pinView.glyphTintColor = UIColor.white
                    pinView.glyphImage = UIImage(named: "ic_pin_crosshairs_gps_white_20pt")
                    pinView.selectedGlyphImage = UIImage(named: "ic_pin_crosshairs_gps_white_40pt")
                    
                    view = pinView
                } else if pinAnnotation.tipoCiudad == "destino" {
                    let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pinDestino")
                    pinView.markerTintColor = ColorPalette.Urbano.rojo
                    pinView.glyphTintColor = UIColor.white
                    pinView.glyphImage = UIImage(named: "ic_pin_map_marker_white_20pt")
                    pinView.selectedGlyphImage = UIImage(named: "ic_pin_map_marker_white_40pt")
                    
                    view = pinView
                }
                
            }
        } else {
            view?.annotation = annotation
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        /*if let annotation = view.annotation! as? PinAnnotation {
         let index = agenciasPin.index(of: annotation)!
         selectedIndexAgencia = index
         fetchFechas()
         }*/
    }
    
}

extension ResultadoCotizacionVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

class PinCiudadAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var tipoCiudad: String?
    
    init(title: String, subtitle: String, tipoCiudad: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.tipoCiudad = tipoCiudad
        self.coordinate = coordinate
    }
}
