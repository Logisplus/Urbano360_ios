//
//  CalificarServicioModels.swift
//  Urbano
//
//  Created by Mick VE on 2/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct CalificarServicio {
    struct FetchDetalleCalificacionServicio {
        struct Request {
            var guiNumero: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            var data: [DetalleCalificacion]
            let code_error: String
            
            struct DetalleCalificacion: Decodable {
                let error_sql: String
                let error_info: String
                let id_loyalty: String
                let cant_estrellas: String
                let fecha: String
                let apuntes: String
            }
        }
    }
    
    struct UploadCalificacionServicio {
        struct Request {
            var guiNumero: String
            var estrellas: String
            var comentario: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            //var data: [Notificacion]
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

typealias FetchDetalleCalificacionServicioRequest = CalificarServicio.FetchDetalleCalificacionServicio.Request
typealias FetchDetalleCalificacionServicioResponse = CalificarServicio.FetchDetalleCalificacionServicio.Response

typealias UploadCalificacionServicioRequest = CalificarServicio.UploadCalificacionServicio.Request
typealias UploadCalificacionServicioResponse = CalificarServicio.UploadCalificacionServicio.Response
