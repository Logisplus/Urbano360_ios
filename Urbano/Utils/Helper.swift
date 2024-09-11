//
//  Helper.swift
//  Urbano
//
//  Created by Mick VE on 24/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Helper {
    
    public static func showLoginView(viewController: UIViewController) {
        let sb = UIStoryboard(name: "Login", bundle: nil)
        let vc = sb.instantiateInitialViewController()
        viewController.present(vc!, animated: true, completion: nil)
    }
    
    public static func isValidEmail(email: String) -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) != nil
    }
    
    public static func checkForLocationServices(viewController: UIViewController, locationManager: CLLocationManager) {
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.startUpdatingLocation()
                case .restricted, .denied:
                    let alert = UIAlertController(title: "Urbano no tiene acceso a tu ubicación. Para activarla, pulsa Configuración > Localización", message: nil, preferredStyle: .alert)
                    
                    let ahoraNoAction = UIAlertAction(title: "Ahora No", style: .cancel, handler: nil)
                    
                    let configuracionAction = UIAlertAction(title: "Configuración", style: .default, handler: { (action) in
                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                        //UIApplication.shared.open(URL(string:"App-Prefs:root=General")!)
                    })
                    
                    alert.addAction(ahoraNoAction)
                    alert.addAction(configuracionAction)
                    
                    viewController.present(alert, animated: true, completion: nil)
                case .authorizedWhenInUse, .authorizedAlways:
                    locationManager.startUpdatingLocation()
                }
            } else {
                let alert = UIAlertController(title: "Activa Localización para permitir que \"Urbano\" determine tu ubicación",
                                              message: "Activa el servicio de Localización en Configuración > Privacidad > Localización para usar la función \"mi ubicación\".", preferredStyle: .alert)
                
                let ahoraNoAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alert.addAction(ahoraNoAction)
                
                viewController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
