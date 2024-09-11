//
//  LozalizanosModels.swift
//  Urbano
//
//  Created by Mick VE on 4/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct Localizanos {
    struct FetchAgenciasUrbano {
        struct Request {
            var tipoAgencia: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            let data: [Agencias]
            let code_error: String
            
            struct Agencias: Decodable {
                let ciu_id: String
                let dir_id: String
                let dir_calle: String
                let prov_codigo: String
                let prov_descri: String
                let telefonos: String
                let contactos: String
                let foto: String
                let icono: String
                let img_path: String
                let x: String
                let y: String
            }
        }
    }
}

typealias FetchAgenciasUrbanoRequest = Localizanos.FetchAgenciasUrbano.Request
typealias FetchAgenciasUrbanoResponse = Localizanos.FetchAgenciasUrbano.Response
