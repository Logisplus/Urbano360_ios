//
//  ReprogramarVisitaModels.swift
//  Urbano
//
//  Created by Mick VE on 25/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct ReprogramarVisita {
    struct FetchDataReprogramacion {
        struct Request {
            var guiNumero: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            var data: Data
            var code_error: String
            
            struct Data: Decodable {
                var direcciones: [Direccion]
                var reglaNuevaDireccion: String
                var servNotify: ServicioNotificacion
                
                struct Direccion: Decodable {
                    var error_sql: String
                    var error_info: String
                    var dir_id: String
                    var distrito: String
                    var direccion: String
                    var referencia: String
                    var ciu_id: String
                    var px: String
                    var py: String
                }
                
                struct ServicioNotificacion: Decodable {
                    var error_sql: String
                    var error_isam: String
                    var error_info: String
                    var notify_ld: String
                    var notify_dl: String
                    var notify_ca: String
                    var telefono: String
                    var correo: String
                }
            }
        }
    }
    
    struct FetchDistritos {
        struct Request {
            var query: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            var data: [Distrito]
            var code_error: String
            
            struct Distrito: Decodable {
                var error_sql: String
                var error_info: String
                var ciudad: String
                var ciu_id: String
                var ciu_px: String
                var ciu_py: String
                var mapa: String
            }
        }
    }
    
    struct FetchFechas {
        struct Request {
            var guiNumero: String
            var motID: String
            var idAge: String
            var idLocalidad: String
            var idTipoServicio: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            var data: [Fecha]
            var code_error: String
            
            struct Fecha: Decodable {
                var error_sql: String
                var error_info: String
                var fecha: String
            }
        }
    }
    
    struct FetchHorarios {
        struct Request {
            var idLocalidad: String
            var fechaVisita: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            var data: [Horario]
            var code_error: String
            
            struct Horario: Decodable {
                var error_sql: String
                var error_info: String
                var id_arco: String
                var id_horario: String
                var desde: String
                var hasta: String
                var tipo: String
            }
        }
    }
    
    struct UploadAgendarVisita {
        struct Request {
            var guiNumero: String
            var idMotivo: String
            var idDireccion: String
            var idCiudad: String
            var direccionEntrega: String
            var transversal: String
            var nroPuerta: String
            var nroInterior: String
            var referencia: String
            var latitude: String
            var longitude: String
            var fechaVisita: String
            var idHora: String
            var nombreAutorizado: String
            var dniAutorizado: String
            var estadoNotifyLD: String
            var estadoNotifyDL: String
            var estadoNotifyCA: String
            var telefono: String
            var correo: String
            var lineaNegocio: String
            var idUsuario: String
            var idUser: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            //var data: Data
            var code_error: String
        }
    }
    
    struct FetchDetalleReprogramacionVisita {
        struct Request {
            var guiNumero: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            var data: [DetalleReprogramacion]
            var code_error: String
            
            struct DetalleReprogramacion: Decodable {
                var error_sql: String
                var error_isam: String
                var error_info: String
                var gestionista: String
                var comentario: String
                var estado: String
                var hora_llamada: String
                var fecha_programada: String
                var num_telefono: String
                var fecha_llamada: String
                var hora_programada: String
                var chk_id: String
                var id_ges_det: String
                var dir_id: String
                var direccion: String
                var tipo_servicio: String
                var dni_autorizado: String
                var nombre_autorizado: String
                var px: String
                var py: String
            }
        }
    }
    
    struct FetchAgenciasReprogramacion {
        struct Request {
            var guiNumero: String
            var idUsuario: String
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
                let horario: String
                let fecha: String
                let x: String
                let y: String
            }
        }
    }
}

typealias FetchDataReprogramacionRequest = ReprogramarVisita.FetchDataReprogramacion.Request
typealias FetchDataReprogramacionResponse = ReprogramarVisita.FetchDataReprogramacion.Response

typealias FetchDistritosRequest = ReprogramarVisita.FetchDistritos.Request
typealias FetchDistritosResponse = ReprogramarVisita.FetchDistritos.Response

typealias FetchFechasAgendarVisitaRequest = ReprogramarVisita.FetchFechas.Request
typealias FetchFechasAgendarVisitaResponse = ReprogramarVisita.FetchFechas.Response

typealias FetchHorariosAgendarVisitaRequest = ReprogramarVisita.FetchHorarios.Request
typealias FetchHorariosAgendarVisitaResponse = ReprogramarVisita.FetchHorarios.Response

typealias UploadAgendarVisitaRequest = ReprogramarVisita.UploadAgendarVisita.Request
typealias UploadAgendarVisitaResponse = ReprogramarVisita.UploadAgendarVisita.Response

typealias FetchDetalleReprogramacionVisitaRequest = ReprogramarVisita.FetchDetalleReprogramacionVisita.Request
typealias FetchDetalleReprogramacionVisitaResponse = ReprogramarVisita.FetchDetalleReprogramacionVisita.Response

typealias FetchAgenciasReprogramacionRequest = ReprogramarVisita.FetchAgenciasReprogramacion.Request
typealias FetchAgenciasReprogramacionResponse = ReprogramarVisita.FetchAgenciasReprogramacion.Response
