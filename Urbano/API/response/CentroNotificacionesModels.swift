//
//  CentroNotificacionesModels.swift
//  Urbano
//
//  Created by Mick VE on 11/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct CentroNotificaciones {
    struct FetchCentroNotificaciones {
        struct Request {
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            var data: [Notificacion]
            let code_error: String
            
            struct Notificacion: Decodable {
                let error_sql: String
                let error_info: String
                let id_notify: String
                let notificacion: String
                let fecha_notificacion: String
                let n_veces: String
                let titulo: String
                let guia: String
            }
        }
    }
}

typealias FetchCentroNotificacionesRequest = CentroNotificaciones.FetchCentroNotificaciones.Request
typealias FetchCentroNotificacionesResponse = CentroNotificaciones.FetchCentroNotificaciones.Response
