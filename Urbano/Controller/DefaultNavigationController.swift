//
//  DefaultNavigationController.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DefaultNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.Urbano.rojo
        
        navigationBar.barStyle = .black
        navigationBar.barTintColor = ColorPalette.Urbano.rojo
        navigationBar.backgroundColor = ColorPalette.Urbano.rojo
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor.white
        navigationBar.prefersLargeTitles = true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
