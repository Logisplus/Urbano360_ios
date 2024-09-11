//
//  LocalizanosViewController.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class LocalizanosViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GMSAutocompleteResultsViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tipoAgenciasSegmentControl: UISegmentedControl!
    
    var agencias: [Localizanos.FetchAgenciasUrbano.Response.Agencias]?
    var agenciasPin = [PinAnnotation]()
    
    var selectedIndexAgencia = -1
    
    var tipoAgencia = "1"
    var markerTintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
    var glyphImage = UIImage(named: "ic_pin_logo_urbano_20pt")
    var selectedGlyphImage = UIImage(named: "ic_pin_logo_urbano_20pt")
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var autocompleteResultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        createSearchView()
        tipoAgenciasSegmentControl.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
        
        setupMapView()
        setupMKUserTrackingButton()
        setupLocationManager()
        fetchAgenciasUrbano()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.definesPresentationContext = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.definesPresentationContext = false;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueLocalizanosToDetalleAgencia" {
            let vc = segue.destination as! DetalleAgenciaTableViewController
            vc.agencia = agencias![selectedIndexAgencia]
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Action Views
    @IBAction func tipoAgenciasDidSelect(_ sender: Any) {
        switch tipoAgenciasSegmentControl.selectedSegmentIndex {
        case 0:
            tipoAgencia = "1"
            markerTintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
            glyphImage = UIImage(named: "ic_pin_logo_urbano_20pt")
            selectedGlyphImage = UIImage(named: "ic_pin_logo_urbano_20pt")
        case 1:
            tipoAgencia = "2"
            markerTintColor = RastrearEnvioViewController.PalleteColorUrbano.gris
            glyphImage = UIImage(named: "ic_pin_counter_20pt")
            selectedGlyphImage = UIImage(named: "ic_pin_counter_40pt")
        case 2:
            tipoAgencia = "3"
            markerTintColor = RastrearEnvioViewController.PalleteColorUrbano.negro
            glyphImage = UIImage(named: "ic_pin_pickup_20pt")
            selectedGlyphImage = UIImage(named: "ic_pin_pickup_40pt")
        default:
            print("El tipo de agencia es desconocido.")
        }
        
        fetchAgenciasUrbano()
    }
    
    // MARK: MKView Delegate
    
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
                pinView.markerTintColor = markerTintColor
                pinView.glyphTintColor = UIColor.white
                pinView.glyphImage = glyphImage
                pinView.selectedGlyphImage = selectedGlyphImage
                view = pinView
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation! as? PinAnnotation {
            let index = agenciasPin.index(of: annotation)!
            selectedIndexAgencia = index
            self.performSegue(withIdentifier: "segueLocalizanosToDetalleAgencia", sender: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        mapView.userTrackingMode = .none
        checkForLocationServices()
    }
    
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
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
        searchController!.isActive = false
        /*print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")*/
        
        if let _ = place.viewport {
            let swPoint = MKMapPointForCoordinate(place.viewport!.southWest)
            let swRect = MKMapRectMake(swPoint.x, swPoint.y, 0, 0)
            let nePoint = MKMapPointForCoordinate(place.viewport!.northEast)
            let neRect = MKMapRectMake(nePoint.x, nePoint.y, 0, 0)
            let rect = MKMapRectUnion(swRect, neRect)
            mapView.setVisibleMapRect(rect, animated: true)
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func createSearchView() {
        /*let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Buscar lugar o dirección"
        //searchBar.delegate = self
        searchBar.scopeButtonTitles = scopeButtonTitles
        searchBar.showsScopeBar = true
        let color: UIColor = UIColor(red: CGFloat(209/255.0), green: CGFloat(51/255.0), blue: CGFloat(57/255.0), alpha: CGFloat(1.0) )
        searchBar.tintColor = color
        self.navigationItem.titleView = searchBar*/
        
        /*if #available(iOS 11.0, *) {
            let viewController = UIStoryboard(name: "GuiaSearch", bundle: nil).instantiateInitialViewController()
            let searchController = UISearchController(searchResultsController: viewController)
            /*searchController.delegate = self
            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self*/
            searchController.searchBar.tintColor = UIColor.white
            searchController.searchBar.placeholder = "Buscar lugar o dirección"
        
            navigationItem.titleView = searchController.searchBar
            
            //navigationItem.searchController = searchController
            //navigationItem.hidesSearchBarWhenScrolling = true
        }*/
        
        autocompleteResultsViewController = GMSAutocompleteResultsViewController()
        autocompleteResultsViewController!.delegate = self
        
        searchController = UISearchController(searchResultsController: autocompleteResultsViewController!)
        searchController!.searchResultsUpdater = autocompleteResultsViewController!
        searchController!.hidesNavigationBarDuringPresentation = false
        searchController!.dimsBackgroundDuringPresentation = true
        
        searchController!.searchBar.sizeToFit()
        searchController!.searchBar.placeholder = "Buscar lugar o dirección"
        searchController!.searchBar.searchBarStyle = .minimal
        searchController!.searchBar.isTranslucent = true
        searchController!.searchBar.tintColor = UIColor.white
        searchController!.searchBar.barTintColor = UIColor.white
        
        let textFieldInsideSearchBar = searchController!.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        textFieldInsideSearchBar?.tintColor = UIColor.white
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: CGFloat(255/255.0), green: CGFloat(255/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(0.18))
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor(red: CGFloat(255/255.0), green: CGFloat(255/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(0.5))
        
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor(red: CGFloat(255/255.0), green: CGFloat(255/255.0), blue: CGFloat(255/255.0), alpha: CGFloat(0.5))
        
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        navigationItem.titleView = searchController!.searchBar
        //navigationItem.searchController = searchController!
        
        /*if UI_USER_INTERFACE_IDIOM() == .pad {
            searchController!.modalPresentationStyle = .popover
        } else {
            searchController!.modalPresentationStyle = .fullScreen
        }*/
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
    
    func setupMapView() {
        mapView.mapType = .standard
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkForLocationServices() {
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
                    self.locationManager.startUpdatingLocation()
                case .restricted, .denied:
                    let alert = UIAlertController(title: "Urbano no tiene acceso a tu ubicación. Para activarla, pulsa Configuración > Localización", message: nil, preferredStyle: .alert)
                    
                    let ahoraNoAction = UIAlertAction(title: "Ahora No", style: .cancel, handler: nil)
                    
                    let configuracionAction = UIAlertAction(title: "Configuración", style: .default, handler: { (action) in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                        //UIApplication.shared.open(URL(string:"App-Prefs:root=General")!)
                    })
                    
                    alert.addAction(ahoraNoAction)
                    alert.addAction(configuracionAction)
                    
                    self.present(alert, animated: true, completion: nil)
                case .authorizedWhenInUse, .authorizedAlways:
                    self.locationManager.startUpdatingLocation()
                }
            } else {
                let alert = UIAlertController(title: "Activa Localización para permitir que \"Urbano\" determine tu ubicación",
                                              message: "Activa el servicio de Localización en Configuración > Privacidad > Localización para usar la función \"mi ubicación\".", preferredStyle: .alert)
                
                let ahoraNoAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                alert.addAction(ahoraNoAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /*func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
     searchBar.text = ""
     searchBar.setShowsCancelButton(false, animated: true)
     searchBar.endEditing(true)
     }
     
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
     print("call searchBarTextDidBeginEditing")
     searchBar.setShowsCancelButton(true, animated: true)
     }*/
    
    func fetchAgenciasUrbano() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        self.present(loadingViewController, animated: true, completion: nil)
        
        let params = FetchAgenciasUrbanoRequest(tipoAgencia: tipoAgencia)
        
        API.fetchAgenciasUrbano(params: params) { (data, error) in
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
                        self.checkForLocationServices()
                    }
                })
            }
        }
    }
    
    func loadDataForMap(agencias: [Localizanos.FetchAgenciasUrbano.Response.Agencias]) {
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
