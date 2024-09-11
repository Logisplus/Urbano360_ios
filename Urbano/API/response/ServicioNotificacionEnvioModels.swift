//
//  ServicioNotificacionEnvioModels.swift
//  Urbano
//
//  Created by Mick VE on 2/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct ServicioNotificacionEnvio {
    struct FetchNotificaciones {
        struct Request {
            var guiNumero: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            let data: [Notificaciones]
            let code_error: String
            
            struct Notificaciones: Decodable {
                let error_sql: String
                let error_isam: String
                let error_info: String
                let id_notify: String
                let descri_notify: String
                var estado: String
                let telefono: String
                let correo: String
            }
        }
    }
    
    struct UploadNotificaciones {
        struct Request {
            var guiNumero: String
            var notificaciones: String
            var correo: String
            var telefono: String
            var lineaNegocio: String
            var idUsuario: String
            
            struct Notificaciones: Encodable {
                var id_notify: String
                var estado: String
            }
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            let code_error: String
        }
    }
}

typealias FetchServicioNotificacionEnvioRequest = ServicioNotificacionEnvio.FetchNotificaciones.Request
typealias FetchServicioNotificacionEnvioResponse = ServicioNotificacionEnvio.FetchNotificaciones.Response

typealias UploadServicioNotificacionEnvioRequest = ServicioNotificacionEnvio.UploadNotificaciones.Request
typealias UploadServicioNotificacionEnvioResponse = ServicioNotificacionEnvio.UploadNotificaciones.Response
