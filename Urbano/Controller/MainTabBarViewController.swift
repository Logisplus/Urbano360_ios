//
//  MainTabBarViewController.swift
//  Urbano
//
//  Created by Mick VE on 15/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    var deeplink: DeeplinkType? {
        didSet {
            handleDeeplink()
        }
    }
    
    enum DeeplinkType {
        case rastrearEnvio(guia: String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleDeeplink() {
        switch deeplink! {
        case .rastrearEnvio(guia: let guia):
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
                let sb = UIStoryboard(name: "BuscarGuia", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "RastrearEnvioStoryboard") as! RastrearEnvioViewController
                vc.searchGuia = guia
                vc.isVisibleCancelButton = true
                let nv = DefaultNavigationController(rootViewController: vc)
                self.present(nv, animated: true, completion: nil)
            }
        }
    }

}
