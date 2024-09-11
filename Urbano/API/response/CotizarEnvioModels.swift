//
//  CotizarEnvioModels.swift
//  Urbano
//
//  Created by Mick VE on 20/09/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct CotizarEnvio {
    struct CotizarEnvio {
        struct Request {
            var idCiudadOrigen: String
            var idCiudadDestino: String
            var tipoProducto: String
            var pesoPaquete: String
            var anchoPaquete: String
            var altoPaquete: String
            var largoPaquete: String
            var valorDeclarado: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            var data: [ResultadoCotizacion]
            let code_error: String
            
            struct ResultadoCotizacion: Decodable {
                var error_sql: String
                var error_info: String
                var valor_ennvio: String
                var time_envio: String
                var valor_envio_aereo: String
                var time_aereo: String
            }
        }
    }
    
    struct FetchDepartamentos {
        struct Request {
            var id: String
            var idUsuario: String
        }
        
        struct Response: Decodable {
            var success: Bool
            var msg_error: String
            var data: [Departamento]
            var code_error: String
            
            struct Departamento: Decodable {
                var error_sql: String
                var error_info: String
                var id_dep: String
                var nombre: String
            }
        }
    }
    
    struct FetchDistritosPorDepartamento {
        struct Request {
            var query: String
            var idDepartamento: String
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
                var distrito: String
                var provincia: String
                var departamento: String
                var ciu_id: String
                var ciu_px: String
                var ciu_py: String
                var cobertura: String
            }
        }
    }
}

typealias FetchDepartamentosRequest = CotizarEnvio.FetchDepartamentos.Request
typealias FetchDepartamentosResponse = CotizarEnvio.FetchDepartamentos.Response

typealias FetchDistritosPorDepartamentoRequest = CotizarEnvio.FetchDistritosPorDepartamento.Request
typealias FetchDistritosPorDepartamentoResponse = CotizarEnvio.FetchDistritosPorDepartamento.Response

typealias FetchCotizarEnvioRequest = CotizarEnvio.CotizarEnvio.Request
typealias FetchCotizarEnvioResponse = CotizarEnvio.CotizarEnvio.Response
