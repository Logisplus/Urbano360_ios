//
//  MapaEnvioVCDelegate.swift
//  Urbano
//
//  Created by Mick VE on 7/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

protocol MapaEnvioVCDelegate {
    func updateNewGPSCourier(latitude: String, longitude: String, idCHK: String, entregasPendientes: String, horarioEntrega: String)
    func updateDetalleRastreoEnvio(data: FetchEnvioResponse)
}
