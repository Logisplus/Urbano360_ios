//
//  BuscarDistritoVCDelegate.swift
//  Urbano
//
//  Created by Mick VE on 27/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

protocol BuscarDistritoVCDelegate {
    func distritoDidSelect(distrito: FetchDistritosResponse.Distrito)
}
