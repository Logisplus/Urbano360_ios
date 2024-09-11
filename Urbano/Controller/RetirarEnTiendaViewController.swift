//
//  RetirarEnTiendaViewController.swift
//  Urbano
//
//  Created by Mick VE on 30/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MapKit

class RetirarEnTiendaViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var guiaNumero: String?
    var lineaNegocio: String?
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var agencias: [ReprogramarVisita.FetchAgenciasReprogramacion.Response.Agencias]?
    var agenciasPin = [PinAnnotation]()
    
    var selectedIndexAgencia = -1
    
    var fechaAproximadaParaRetirar: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        navigationItem.backBarButtonItem = backItem
        
        setupMapView()
        setupMKUserTrackingButton()
        setupLocationManager()
        fetchAgenciasReprogramacion()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromMapaToDetalle" {
            let vc = segue.destination as! DetalleRetirarEnTiendaVC
            vc.guiaNumero = guiaNumero!
            vc.lineaNegocio = lineaNegocio!
            vc.agencia = agencias![selectedIndexAgencia]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupMapView() {
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func setupMKUserTrackingButton() {
        let usertrackingButton = MKUserTrackingButton(mapView: mapView)
        view.addSubview(usertrackingButton)
        usertrackingButton.backgroundColor = UIColor.white
        usertrackingButton.layer.cornerRadius = 4
        usertrackingButton.tintColor =  RastrearEnvioViewController.PalleteColorUrbano.rojo
        usertrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: usertrackingButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: 10))
        view.addConstraint(NSLayoutConstraint(item: usertrackingButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: -10))
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func fetchAgenciasReprogramacion() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = FetchAgenciasReprogramacionRequest(guiNumero: self.guiaNumero!, idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.getAgenciasReprogramacion(params: params) { (data, error) in
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
                                    
                                    self.agencias = data.data
                                    self.loadDataForMap(agencias: data.data)
                                    Helper.checkForLocationServices(viewController: self, locationManager: self.locationManager)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func fetchFechas() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = FetchFechasAgendarVisitaRequest(guiNumero: self.guiaNumero!,
                                                     motID: "105",
                                                     idAge: agencias![selectedIndexAgencia].prov_codigo,
                                                     idLocalidad: agencias![selectedIndexAgencia].ciu_id,
                                                     idTipoServicio: "19",
                                                     lineaNegocio: self.lineaNegocio!,
                                                     idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.fetchFechasAgendarVisita(params: params) { (data, error) in
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
                                    
                                    self.fechaAproximadaParaRetirar = data.data[0].fecha
                                    self.performSegue(withIdentifier: "segueFromMapaToDetalle", sender: nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func loadDataForMap(agencias: [ReprogramarVisita.FetchAgenciasReprogramacion.Response.Agencias]) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.agenciasPin)
            self.agenciasPin.removeAll()
            for agencia in agencias {
                if let x = Double(agencia.x), let y = Double(agencia.y), (x != 0 && y != 0) {
                    let location = CLLocationCoordinate2DMake(x, y)
                    let pin = PinAnnotation(title: agencia.prov_descri.capitalized, subtitle: agencia.dir_calle.capitalized, coordinate: location)
                    self.mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
                    //mapView.setRegion(MKCoordinateRegionMakeWithDistance(location, 1000, 1000), animated: true)
                    self.agenciasPin.append(pin)
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }
    
}

extension RetirarEnTiendaViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if view == nil {
            view?.annotation = annotation
        } else {
            if let _ = annotation as? PinAnnotation {
                let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                pinView.markerTintColor = ColorPalette.Urbano.negro
                pinView.glyphTintColor = UIColor.white
                pinView.glyphImage = UIImage(named: "ic_pin_pickup_20pt")
                pinView.selectedGlyphImage = UIImage(named: "ic_pin_pickup_40pt")
                view = pinView
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation! as? PinAnnotation {
            let index = agenciasPin.index(of: annotation)!
            selectedIndexAgencia = index
            self.performSegue(withIdentifier: "segueFromMapaToDetalle", sender: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        mapView.userTrackingMode = .none
        Helper.checkForLocationServices(viewController: self, locationManager: self.locationManager)
    }
    
}

extension RetirarEnTiendaViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 30000, 30000)
                mapView.setRegion(viewRegion, animated: true)
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
}
