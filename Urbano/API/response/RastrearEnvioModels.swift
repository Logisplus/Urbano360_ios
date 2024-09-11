//
//  RastrearEnvioModels.swift
//  Urbano
//
//  Created by Mick VE on 21/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct RastrearEnvio {
    struct FetchEnvio {
        struct Request {
            var guia: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: [String]
            var data: [Data]
            let code_error: [String]
            
            struct Data: Decodable {
                var eTracking: ETracking
                let historialTransporte: [HistorialTransporte]
                
                struct ETracking: Decodable {
                    var error_sql: String
                    var error_info: String
                    var guia_texto: String
                    var fecha_ao: String
                    var rastreo: String
                    var origen: String
                    var destino: String
                    var localidad: String
                    var telefonos: String
                    var e_mail: String
                    var remite: String
                    var cliente: String
                    var piezas: String
                    var peso: String
                    var chk_descripcion: String
                    var und_placa: String
                    var fecha_pu: String
                    var fecha_dd: String
                    var fecha_ad: String
                    var fecha_er: String
                    var fecha_dl: String
                    var id_proceso: String
                    var dir_px: String
                    var dir_py: String
                    var gps_px: String
                    var gps_py: String
                    var hora_estimado: String
                    var direccion: String
                    var icono_shipper: String
                    var chk: String
                    var guia: String
                    var descripcion_paquete: String
                    var id_pesos: String
                    var servicio: String
                    var cod_importe: String
                    var ge_alerta: String
                    var view_detalle: String
                    var novedades: String
                    var dir_id: String
                    var chk_id: String
                    var nro_visita: String
                    var nom_courier: String
                    var fecha_mov: String
                    var nom_destinatario_entrega: String
                    var dni_destinatario_entrega: String
                    var comentarios: String
                    var id_visita: String
                    var mot_descripcion: String
                    var fecha_chk: String
                    var reprogramacion: String
                    var retiro_tienda: String
                    var linea_negocio: String
                    var referencia: String
                    var overnight: String
                    var weekend: String
                    var cod_tipo: String
                    var tipo_seguimiento: String
                    var tipo_unidad: String
                    var pend_agendamiento: String
                    var ge_faltante: String
                    var horario_ge: String
                }
                
                struct HistorialTransporte: Decodable {
                    let sql_error: String
                    let msg_error: String
                    let fecha: String
                    let hora: String
                    let motivo_movimiento: String
                    let descripcion_movimiento: String
                    let id_visita: String
                    let chk: String
                    let gps_px: String
                    let gps_py: String
                    let nro_visita: String
                    let chk_nombre: String
                    let chk_id: String
                    let fotosVisita: [FotosVisita]
                    
                    struct FotosVisita: Decodable {
                        let sql_error: String
                        let msg_error: String
                        let img_path: String
                        let img_fecha_hora: String
                        let img_tipo: String
                        let img_px: String
                        let img_py: String
                        let img_id: String
                    }
                }
            }
        }
    }
    
    struct FetchGPSCourier {
        struct Request {
            var guiNumero: String
            var lineaNegocio: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            var data: [GPSCourier]
            var code_error: String
            
            struct GPSCourier: Decodable {
                var error_sql: String
                var error_info: String
                var gps_x: String
                var gps_y: String
                var chk_id: String
                var ge_faltante: String
                var horario_ge: String
            }
        }
    }
}

typealias FetchEnvioRequest = RastrearEnvio.FetchEnvio.Request
typealias FetchEnvioResponse = RastrearEnvio.FetchEnvio.Response

typealias FetchGPSCourierRequest = RastrearEnvio.FetchGPSCourier.Request
typealias FetchGPSCourierResponse = RastrearEnvio.FetchGPSCourier.Response
