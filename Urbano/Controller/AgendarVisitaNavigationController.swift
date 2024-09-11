//
//  AgendarVisitaNavigationController.swift
//  Urbano
//
//  Created by Mick VE on 25/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class AgendarVisitaNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = ColorPalette.Urbano.rojo
        
        navigationBar.barStyle = .blackOpaque
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor.white
        navigationBar.shadowImage = UIImage()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
