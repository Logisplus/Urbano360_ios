//
//  ListaDireccionesVCDelegate.swift
//  Urbano
//
//  Created by Mick VE on 27/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

protocol ListaDireccionesVCDelegate {
    func distritoDidSelect(index: Int)
    func referenciaDidChange(index: Int, referencia: String)
    func coordenadaDidChange(index: Int, latitude: String, longitude: String)
}
