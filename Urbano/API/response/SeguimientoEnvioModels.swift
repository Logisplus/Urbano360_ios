//
//  SeguimientoEnvioModels.swift
//  Urbano
//
//  Created by Mick VE on 3/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct SeguimientoEnvio {
    struct FetchEnviosEnSeguimiento {
        struct Request {
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            var data: [Envio]
            let code_error: String
            
            struct Envio: Decodable {
                let error_sql: String
                let error_isam: String
                let error_info: String
                let guia: String
                let barra: String
                let estado: String
                var detalle: String
                var fecha: String
                let pend_agendamiento: String
                let notify: String
                let chk_id: String
                let linea: String
            }
        }
    }
    
    struct MarcarSeguimientoEnvio {
        struct Request {
            var guiNumero: String
            var estado: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            let code_error: String
        }
    }
}

typealias FetchEnviosEnSeguimientoRequest = SeguimientoEnvio.FetchEnviosEnSeguimiento.Request
typealias FetchEnviosEnSeguimientoResponse = SeguimientoEnvio.FetchEnviosEnSeguimiento.Response

typealias MarcarSeguimientoEnvioResponse = SeguimientoEnvio.MarcarSeguimientoEnvio.Response
