//
//  MapaEnvioController.swift
//  Urbano
//
//  Created by Mick VE on 4/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

class MapaEnvioController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var detalleCourierController: DetalleCourierController?
    
    var eTracking: FetchEnvioResponse.Data.ETracking?
    
    var importePorCobrarBoxContainerView: UIView?
    
    var entregasPendientesBoxContainerView: UIView?
    var entregasPendientesLabel: UILabel?
    
    var repeatingTimer: RepeatingTimer?
    
    var delegate: MapaEnvioVCDelegate?
    
    var direccionPinAnnotation: PinTrackingAnnotation?
    var courierPinAnnotation: PinTrackingAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        repeatingTimer = RepeatingTimer(timeInterval: 60)
        repeatingTimer!.eventHandler = {
            print("Timer Fired")
            self.getGPSCourierRequest()
        }
        repeatingTimer!.resume()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        self.repeatingTimer?.suspend()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func entregasPendientesBoxViewDidTap(_ sender: UITapGestureRecognizer) {
        showEntregasPendientesAlert()
    }
    
    @objc func importePorCobrarBoxViewDidTap(_ sender: UITapGestureRecognizer) {
        if !eTracking!.cod_importe.isEmpty {
            let alert = UIAlertController(title: "Valor pendiente por pagar",
                                          message: "Hay un valor pendiente de \(eTracking!.cod_importe) por pagar, recuerda tenerlo disponible al momento de recibir tu envío.",
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupViews() {
        self.navigationItem.largeTitleDisplayMode = .never
        
        setupMapView()
        
        setupMKUserTrackingButton()
        
        setupLocationManager()
        
        setupPinsMapView()
        
        addPullUpController()
        
        setupBoxEntregasPendientes()
        showEntregasPendientesAlert()
        
        setupBoxImportePorCobrar()
    }
    
    func setupMapView() {
        mapView.mapType = .standard
        mapView.showsCompass = false
        mapView.showsScale = true
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
    }
    
    func setupMKUserTrackingButton() {
        let usertrackingButton = MKUserTrackingButton(mapView: mapView)
        view.addSubview(usertrackingButton)
        usertrackingButton.backgroundColor = UIColor.white
        usertrackingButton.layer.cornerRadius = 4
        usertrackingButton.tintColor =  RastrearEnvioViewController.PalleteColorUrbano.rojo
        usertrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: usertrackingButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: usertrackingButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: 10))
        
        let compassButton = MKCompassButton(mapView: mapView)
        view.addSubview(compassButton)
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: compassButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: usertrackingButton, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -2))
        view.addConstraint(NSLayoutConstraint(item: compassButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: usertrackingButton, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 10))
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func setupPinsMapView() {
        var coordinateCourier: CLLocationCoordinate2D?
        var coordinateDireccion: CLLocationCoordinate2D?
        
        if let x = Double(eTracking!.dir_px), let y = Double(eTracking!.dir_py), (x != 0 && y != 0) {
            coordinateDireccion = CLLocationCoordinate2D(latitude: x, longitude: y)
            direccionPinAnnotation = PinTrackingAnnotation(title: "", subtitle: "", typePin: "direccion", coordinate: coordinateDireccion!)
            //mapView.setRegion(MKCoordinateRegionMakeWithDistance(location, 1000, 1000), animated: true)
            //self.agenciasPin.append(pin)
            self.mapView.addAnnotation(direccionPinAnnotation!)
        }
        
        if let x = Double(eTracking!.gps_px), let y = Double(eTracking!.gps_py), (x != 0 && y != 0) {
            coordinateCourier = CLLocationCoordinate2D(latitude: x, longitude: y)
            courierPinAnnotation = PinTrackingAnnotation(title: "", subtitle: "", typePin: "courier", coordinate: coordinateCourier!)
            //mapView.setRegion(MKCoordinateRegionMakeWithDistance(location, 1000, 1000), animated: true)
            //self.agenciasPin.append(pin)
            self.mapView.addAnnotation(courierPinAnnotation!)
        }
        
        if coordinateCourier != nil && coordinateDireccion != nil {
            setVisibleMapRectFromBounds(coordinateA: coordinateCourier!, coordinateB: coordinateDireccion!)
            if let entregasPendientes = Int(eTracking!.ge_faltante), entregasPendientes <= 2 {
                getGoogleDirectionsRequest(origin: "\(coordinateCourier!.latitude), \(coordinateCourier!.longitude)",
                    destination: "\(coordinateDireccion!.latitude), \(coordinateDireccion!.longitude)")
            }
        } else {
            Helper.checkForLocationServices(viewController: self, locationManager: self.locationManager)
        }
    }
    
    func addPullUpController() {
        detalleCourierController = self.storyboard!.instantiateViewController(withIdentifier: "DetalleCourierStoryboard") as? DetalleCourierController
        detalleCourierController!.eTracking = eTracking!
        
        addPullUpController(detalleCourierController!)
    }
    
    func setupBoxEntregasPendientes() {
        if let entregasPendientes = Int(eTracking!.ge_faltante), entregasPendientes > 2 {
            entregasPendientesBoxContainerView = UIView(frame: CGRect.zero)
            entregasPendientesBoxContainerView!.translatesAutoresizingMaskIntoConstraints = false
            entregasPendientesBoxContainerView!.backgroundColor = ColorPalette.Urbano.rojo
            entregasPendientesBoxContainerView!.layer.cornerRadius = 25.0
            entregasPendientesBoxContainerView!.layer.borderColor = UIColor(red: 204.0/255.0, green: 23.0/255.0, blue: 31.0/255.0, alpha: 1.0).cgColor
            entregasPendientesBoxContainerView!.layer.borderWidth = 3.0
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(entregasPendientesBoxViewDidTap(_:)))
            entregasPendientesBoxContainerView!.addGestureRecognizer(tapGesture)
            self.view.addSubview(entregasPendientesBoxContainerView!)
            
            var horConstraint = NSLayoutConstraint(item: entregasPendientesBoxContainerView!, attribute: .trailing, relatedBy: .equal,
                                                   toItem: self.view, attribute: .trailingMargin,
                                                   multiplier: 1.0, constant: 10.0)
            var verConstraint = NSLayoutConstraint(item: entregasPendientesBoxContainerView!, attribute: .bottom, relatedBy: .equal,
                                                   toItem: detalleCourierController!.view, attribute: .top,
                                                   multiplier: 1.0, constant: -15.0)
            let widConstraint = NSLayoutConstraint(item: entregasPendientesBoxContainerView!, attribute: .width, relatedBy: .equal,
                                                   toItem: nil, attribute: .width,
                                                   multiplier: 1.0, constant: 50.0)
            let heiConstraint = NSLayoutConstraint(item: entregasPendientesBoxContainerView!, attribute: .height, relatedBy: .equal,
                                                   toItem: nil, attribute: .width,
                                                   multiplier: 1.0, constant: 50.0)
            
            self.view.addConstraints([horConstraint, verConstraint, widConstraint, heiConstraint])
            
            entregasPendientesLabel = UILabel()
            entregasPendientesLabel!.translatesAutoresizingMaskIntoConstraints = false
            entregasPendientesLabel!.text = eTracking!.ge_faltante
            entregasPendientesLabel!.font = UIFont.preferredFont(forTextStyle: .title2)
            entregasPendientesLabel!.textColor = UIColor.white
            entregasPendientesBoxContainerView!.addSubview(entregasPendientesLabel!)
            
            horConstraint = NSLayoutConstraint(item: entregasPendientesLabel!, attribute: .centerX, relatedBy: .equal,
                                               toItem: entregasPendientesBoxContainerView!, attribute: .centerX,
                                               multiplier: 1.0, constant: 0)
            verConstraint = NSLayoutConstraint(item: entregasPendientesLabel!, attribute: .centerY, relatedBy: .equal,
                                               toItem: entregasPendientesBoxContainerView!, attribute: .centerY,
                                               multiplier: 1.0, constant: 0.0)
            
            entregasPendientesBoxContainerView!.addConstraints([horConstraint, verConstraint])
        } else {
            entregasPendientesBoxContainerView?.removeFromSuperview()
            entregasPendientesLabel?.removeFromSuperview()
        }
    }
    
    func setupBoxImportePorCobrar() {
        if !eTracking!.cod_importe.isEmpty {
            importePorCobrarBoxContainerView = UIView(frame: CGRect.zero)
            importePorCobrarBoxContainerView!.translatesAutoresizingMaskIntoConstraints = false
            importePorCobrarBoxContainerView!.backgroundColor = UIColor(red: 24.0/255.0, green: 155.0/255.0, blue: 72.0/255.0, alpha: 1.0)
            importePorCobrarBoxContainerView!.layer.cornerRadius = 25.0
            importePorCobrarBoxContainerView!.layer.borderColor = UIColor(red: 21.0/255.0, green: 133.0/255.0, blue: 62.0/255.0, alpha: 1.0).cgColor
            importePorCobrarBoxContainerView!.layer.borderWidth = 3.0
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(importePorCobrarBoxViewDidTap(_:)))
            importePorCobrarBoxContainerView!.addGestureRecognizer(tapGesture)
            self.view.addSubview(importePorCobrarBoxContainerView!)
            
            var horConstraint = NSLayoutConstraint(item: importePorCobrarBoxContainerView!, attribute: .leading, relatedBy: .equal,
                                                   toItem: self.view, attribute: .leadingMargin,
                                                   multiplier: 1.0, constant: -10.0)
            var verConstraint = NSLayoutConstraint(item: importePorCobrarBoxContainerView!, attribute: .bottom, relatedBy: .equal,
                                                   toItem: detalleCourierController!.view, attribute: .top,
                                                   multiplier: 1.0, constant: -17.0)
            let widConstraint = NSLayoutConstraint(item: importePorCobrarBoxContainerView!, attribute: .width, relatedBy: .equal,
                                                   toItem: nil, attribute: .width,
                                                   multiplier: 1.0, constant: 50.0)
            let heiConstraint = NSLayoutConstraint(item: importePorCobrarBoxContainerView!, attribute: .height, relatedBy: .equal,
                                                   toItem: nil, attribute: .width,
                                                   multiplier: 1.0, constant: 50.0)
            
            self.view.addConstraints([horConstraint, verConstraint, widConstraint, heiConstraint])
            
            let tipoMonedaLabel = UILabel()
            tipoMonedaLabel.translatesAutoresizingMaskIntoConstraints = false
            
            switch UserDefaultsManager.shared.country! {
                case API.Country.Chile, API.Country.Ecuador:
                    tipoMonedaLabel.text = "$"
                case API.Country.Peru:
                    tipoMonedaLabel.text = "S/"
            }
            
            tipoMonedaLabel.font = UIFont.preferredFont(forTextStyle: .title2)
            tipoMonedaLabel.textColor = UIColor(red: 231.0/255.0, green: 230.0/255.0, blue: 23.0/255.0, alpha: 1.0)
            importePorCobrarBoxContainerView!.addSubview(tipoMonedaLabel)
            
            horConstraint = NSLayoutConstraint(item: tipoMonedaLabel, attribute: .centerX, relatedBy: .equal,
                                               toItem: importePorCobrarBoxContainerView!, attribute: .centerX,
                                               multiplier: 1.0, constant: 0)
            verConstraint = NSLayoutConstraint(item: tipoMonedaLabel, attribute: .centerY, relatedBy: .equal,
                                               toItem: importePorCobrarBoxContainerView!, attribute: .centerY,
                                               multiplier: 1.0, constant: 0.0)
            
            importePorCobrarBoxContainerView!.addConstraints([horConstraint, verConstraint])
        }
    }
    
    func showEntregasPendientesAlert() {
        if let entregasPendientes = Int(eTracking!.ge_faltante), entregasPendientes > 2 {
            var mensaje = ""
            
            if entregasPendientes > 6 {
                mensaje = "Tu entrega la realizaremos en horas de la "
                mensaje += eTracking!.horario_ge.lowercased() == "am" ? "mañana, " : "tarde, "
                mensaje += "tenemos \(entregasPendientes) entregas previa a la tuya."
            } else if entregasPendientes == 6 || entregasPendientes == 5 {
                mensaje = "Tu entrega esta a 2 horas aproximadamente, tenemos \(entregasPendientes) entregas previa a la tuya."
            } else if entregasPendientes == 4 {
                mensaje = "Tu entrega esta a 1 hora aproximadamente, tenemos \(entregasPendientes) entregas previa a la tuya."
            } else if entregasPendientes == 3 {
                mensaje = "Tu entrega esta a 30 minutos aproximadamente, tenemos \(entregasPendientes) entregas previa a la tuya."
            }
            
            let alert = UIAlertController(title: "Información de tu envío", message: mensaje, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func processNewGPSCourier(data: FetchGPSCourierResponse) {
        // validar que el gps del courier sea un nuevo gps
        if self.eTracking!.gps_px != data.data[0].gps_x
            || self.eTracking!.gps_py != data.data[0].gps_y {
            print("GPS DEL COURIER")
            self.delegate?.updateNewGPSCourier(latitude: data.data[0].gps_x,
                                               longitude: data.data[0].gps_y,
                                               idCHK: data.data[0].chk_id,
                                               entregasPendientes: data.data[0].ge_faltante,
                                               horarioEntrega: data.data[0].horario_ge)
            
            self.eTracking!.gps_px = data.data[0].gps_x
            self.eTracking!.gps_py = data.data[0].gps_y
            self.eTracking!.chk_id = data.data[0].chk_id
            self.eTracking!.ge_faltante = data.data[0].ge_faltante
            self.eTracking!.horario_ge = data.data[0].horario_ge
            
            DispatchQueue.main.async {
                var entregasPendientes = 0
                if let gePendientes = Int(data.data[0].ge_faltante) {
                    entregasPendientes = gePendientes
                    if entregasPendientes <= 2 {
                        self.entregasPendientesBoxContainerView?.removeFromSuperview()
                    } else {
                        self.entregasPendientesLabel?.text = data.data[0].ge_faltante
                    }
                }
                
                if self.courierPinAnnotation != nil && self.direccionPinAnnotation != nil {
                    if let x = Double(data.data[0].gps_x), let y = Double(data.data[0].gps_y), (x != 0 && y != 0) {
                        print("GPS DEL COURIER VALIDO")
                        let newCoordinate = CLLocationCoordinate2D(latitude: x, longitude: y)
                        UIView.animate(withDuration: 2, animations: {
                            print("ANIM PIN")
                            self.courierPinAnnotation!.coordinate = newCoordinate
                        }, completion:  { success in
                            if success {
                                print("ANIMATION SUCCESS")
                                // handle a successfully ended animation
                                self.setVisibleMapRectFromBounds(coordinateA: self.courierPinAnnotation!.coordinate,
                                                                 coordinateB: self.direccionPinAnnotation!.coordinate)
                                
                                if entregasPendientes <= 2 {
                                    self.getGoogleDirectionsRequest(origin: "\(x), \(y)",
                                        destination: "\(self.eTracking!.dir_px), \(self.eTracking!.dir_py)")
                                }
                            } else {
                                print("ANIMATION FAIL")
                                // handle a canceled animation, i.e move to destination immediately
                                self.courierPinAnnotation!.coordinate = newCoordinate
                                
                                self.setVisibleMapRectFromBounds(coordinateA: self.courierPinAnnotation!.coordinate,
                                                                 coordinateB: self.direccionPinAnnotation!.coordinate)
                                
                                if entregasPendientes <= 2 {
                                    self.getGoogleDirectionsRequest(origin: "\(x), \(y)",
                                        destination: "\(self.eTracking!.dir_px), \(self.eTracking!.dir_py)")
                                }
                            }
                        })
                    } else {
                        print("EL GPS DEL COURIER NO ES VALIDO")
                    }
                }
            }
        } else {
            print("EL GPS DEL COURIER NO ES NUEVO")
        }
    }
    
    func showUrbanoVisitaAlert(data: FetchGPSCourierResponse) {
        DispatchQueue.main.async {
            var title = ""
            if let idCHK = Int(data.data[0].chk_id), idCHK == Constant.CHKControl.ENTREGADO {
                title = "Tu envío fue entregado"
            } else {
                title = "Tu envío no fue entregado"
            }
            
            let alert = UIAlertController(title: title,
                                          message: "Para mas información acerca del estado de tu envío, por favor revise el detalle de la visita.",
                                          preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ver", style: .cancel) { (action:UIAlertAction) in
                self.rastrearEnvioRequest()
            }
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setVisibleMapRectFromBounds(coordinateA: CLLocationCoordinate2D, coordinateB: CLLocationCoordinate2D) {
        let aPoint = MKMapPointForCoordinate(coordinateA)
        let aRect = MKMapRectMake(aPoint.x, aPoint.y, 0, 0)
        let bPoint = MKMapPointForCoordinate(coordinateB)
        let bRect = MKMapRectMake(bPoint.x, bPoint.y, 0, 0)
        let rect = MKMapRectUnion(aRect, bRect)
        self.mapView.setVisibleMapRect(rect,
                                       edgePadding: UIEdgeInsets(top: 100.0, left: 80.0, bottom: 100.0, right: 80.0),
                                       animated: true)
    }
    
    func getGPSCourierRequest() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let params = FetchGPSCourierRequest(guiNumero: eTracking!.guia_texto,
                                            lineaNegocio: eTracking!.linea_negocio,
                                            idUsuario: "1")
        
        DispatchQueue.global().async {
            API.getGPSCourier(params: params) { (data, error) in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let _ = error {
                    print("Lo sentimos, ocurrió un error")
                    print(error)
                    return
                }
                
                if let data = data {
                    guard data.success else {
                        print("Lo sentimos, ocurrió un error")
                        print(data.msg_error)
                        return
                    }
                    
                    print("DATA OK")
                    if data.data.count != 0 {
                        if let idCHK = Int(data.data[0].chk_id), idCHK == Constant.CHKControl.ENTREGADO ||
                            idCHK == Constant.CHKControl.NO_ENTREGADO || idCHK == Constant.CHKControl.CLIENTE_VISITADO {
                            self.showUrbanoVisitaAlert(data: data)
                        } else {
                            self.processNewGPSCourier(data: data)
                        }
                    } else {
                        print("NO HAY GPS DEL COURIER")
                    }
                }
            }
        }
    }
    
    func getGoogleDirectionsRequest(origin: String, destination: String) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let params = GoogleDirectionsRequest(origin: origin, destination: destination)
        
        DispatchQueue.global().async {
            API.getGoogleDirections(params: params) { (data, error) in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if let _ = error {
                    print("Lo sentimos, ocurrió un error")
                    print(error)
                    return
                }
                
                if let data = data {
                    if data.status != "OK" {
                        print("Google Direcctions Error.")
                        return
                    }
                    
                    print("DATA OK DIRECTIONS")
                    
                    let coordinates: [CLLocationCoordinate2D]? = decodePolyline(data.routes[0].overview_polyline.points)
                    
                    let northeastCordinate = CLLocationCoordinate2D(latitude: data.routes[0].bounds.northeast.lat,
                                                                    longitude: data.routes[0].bounds.northeast.lng)
                    let southwestCordinate = CLLocationCoordinate2D(latitude: data.routes[0].bounds.southwest.lat,
                                                                    longitude: data.routes[0].bounds.southwest.lng)
                    
                    DispatchQueue.main.async {
                        self.detalleCourierController?.setTextDescripcionRuta(text: "Llegamos en \(data.routes[0].legs[0].duration.text) aprox.")
                        
                        if let _ = coordinates {
                            let polyline = MKPolyline(coordinates: coordinates!, count: coordinates!.count)
                            print("TOTAL OVERLAYS: \(self.mapView.overlays.count)")
                            if self.mapView.overlays.count != 0 {
                                self.mapView.remove(self.mapView.overlays[0])
                            }
                            self.mapView.add(polyline)
                            self.setVisibleMapRectFromBounds(coordinateA: northeastCordinate, coordinateB: southwestCordinate)
                        } else {
                            print("Error al procesar las coordenadas")
                        }
                    }
                }
            }
        }
    }
    
    func rastrearEnvioRequest() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = FetchEnvioRequest(guia: eTracking!.guia_texto,
                                       lineaNegocio: eTracking!.linea_negocio,
                                       idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.rastrearEnvio(params: params) { (data, error) in
                        DispatchQueue.main.async {
                            loadingViewController.dismiss(animated: true, completion: {
                                if let _ = error {
                                    let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                            message: error,
                                                                            preferredStyle: .alert)
                                    
                                    let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                                    
                                    alertController.addAction(action)
                                    self.present(alertController, animated: true, completion: nil)
                                    return
                                }
                                
                                if let data = data {
                                    guard data.success else {
                                        let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                                message: "\(data.msg_error)",
                                            preferredStyle: .alert)
                                        
                                        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                                        
                                        alertController.addAction(action)
                                        self.present(alertController, animated: true, completion: nil)
                                        return
                                    }
                                    
                                    let sb = UIStoryboard(name: "BuscarGuia", bundle: nil)
                                    let vc = sb.instantiateViewController(withIdentifier: "DetalleVisitaStoryboard") as! DetalleVisitaTableViewController
                                    let eTracking = data.data[0].eTracking
                                    let movimientos = data.data[0].historialTransporte
                                    for movimiento in movimientos {
                                        if movimiento.id_visita == eTracking.id_visita {
                                            vc.eTracking = eTracking
                                            vc.movimientoGuia = movimiento
                                        }
                                    }
                                    
                                    self.delegate?.updateDetalleRastreoEnvio(data: data)
                                    self.navigationController?.popViewController(animated: true)
                                    self.show(vc, sender: nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }

}

extension MapaEnvioController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        
        if view != nil {
            if let pinTrackingAnnotation = annotation as? PinTrackingAnnotation {
                
                if pinTrackingAnnotation.typePin == "courier" {
                    let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pinCourier")
                    pinView.markerTintColor = ColorPalette.Urbano.rojo
                    pinView.glyphTintColor = UIColor.white
                    
                    if let tipoUnidad = Int(eTracking!.tipo_unidad) {
                        if tipoUnidad == 1 {
                            pinView.glyphImage = UIImage(named: "ic_pin_walk_20pt")
                            pinView.selectedGlyphImage = UIImage(named: "ic_pin_walk_40pt")
                        } else if tipoUnidad == 2 {
                            pinView.glyphImage = UIImage(named: "ic_pin_motorbike_20pt")
                            pinView.selectedGlyphImage = UIImage(named: "ic_pin_motorbike_40pt")
                        } else if tipoUnidad == 3 {
                            pinView.glyphImage = UIImage(named: "ic_pin_truck_20pt")
                            pinView.selectedGlyphImage = UIImage(named: "ic_pin_truck_40pt")
                        }
                    }
                    
                    view = pinView
                } else if pinTrackingAnnotation.typePin == "direccion" {
                    let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pinDireccion")
                    pinView.markerTintColor = ColorPalette.Urbano.negro
                    pinView.glyphTintColor = UIColor.white
                    pinView.glyphImage = UIImage(named: "ic_pin_home_20pt")
                    pinView.selectedGlyphImage = UIImage(named: "ic_pin_home_40pt")
                    
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = ColorPalette.Urbano.rojo
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        mapView.userTrackingMode = .none
        Helper.checkForLocationServices(viewController: self, locationManager: self.locationManager)
    }
    
}

extension MapaEnvioController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000)
                mapView.setRegion(viewRegion, animated: true)
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
}

class PinTrackingAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var typePin: String?
    
    init(title: String, subtitle: String, typePin: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.typePin = typePin
        self.coordinate = coordinate
    }
}
