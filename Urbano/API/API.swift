//
//  API.swift
//  Urbano
//
//  Created by Mick VE on 7/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

class API {
    
    struct Scheme {
        static let Production = "https"
        static let Development = "http"
    }
    
    struct Host {
        struct Production {
            static let Chile = "app.urbanoexpress.cl"
            static let Ecuador = "app.urbano.com.ec"
            static let Peru = "app.urbano.com.pe"
        }
        
        struct Development {
            static let Chile = "devel.urbanoexpress.com.pe:8080"
            static let Ecuador = "devel.urbanoexpress.com.pe"
            static let Peru = "devel.urbanoexpress.com.pe"
        }
    }
    
    enum RestPath: String {
        case rastrearGuia
        case getServicioNotificacionEnvio
        case uploadServicioNotificacionEnvio
        case uploadSeguimientoEnvio
        case getAgenciasUrbano
        case getEnviosEnSeguimiento
        case getCentroNotificaciones
        case registerUser
        case getDataReprogramacion
        case searchDistritos
        case getFechasEntregaReprogramacion
        case getHorariosEntregaReprogramacion
        case uploadReprogramacionVisita
        case getDetalleReprogramacionVisita
        case getAgenciasReprogramacion
        case getDetalleCalificacionServicio
        case uploadCalificarServicio
        case getGPSUnidadETracking
        case googleDirections
        case getDepartamentos
        case searchDistritosV3
        case cotizarEnvio
    }
    
    enum Environment: Int {
        case Production
        case Development
    }
    
    enum Country: Int {
        case Chile
        case Ecuador
        case Peru
    }
    
    static let BasePath = "/api-apps/urbano/"

    static func newPost(title: String, author: String, completion: @escaping (Int?, Error?) -> Void) {
        let parameter = ["title": title, "author": author]
        let url = URL(string: "http://localhost:3000/posts")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            
        } catch let error {
            completion(nil, error)
        }
        //G462497
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            print(data!)
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                
                if let dic = result as? [String: Any], let id = dic["id"] as? Int {
                    completion(id, nil)
                } else {
                    completion(nil, nil)
                }
            } catch let error {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    static func rastrearEnvio(params: FetchEnvioRequest, completion: @escaping (FetchEnvioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        /*var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "app.urbano.com.pe"
        urlComponents.path = "/api-apps/urbano/rastrearGuia"*/
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .rastrearGuia)
        
        let queryItemGuia = URLQueryItem(name: "vp_guia", value: params.guia)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemIdUser, queryItemLineaNegocio]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        /*var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        let queryItems = dictionary.map{
            return URLQueryItem(name: "\($0)", value: "\($1)")
        }
        
        urlComponents?.queryItems = queryItems*/
        
        //let parameter = "vp_guia=G462497&vp_id_user=1&vp_linea_negocio=0"
        //urlRequest.httpBody = parameter.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchEnvioResponse.self, from: responseData)
                    DispatchQueue.main.async {
                        completion(decodeBaseResponse, nil)
                    }
                } catch let er {
                    DispatchQueue.main.async {
                        print(er.localizedDescription)
                        completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            }
        }
        task.resume()
    }
    
    static func getServicioNotificacionEnvio(params: FetchServicioNotificacionEnvioRequest, completion: @escaping (FetchServicioNotificacionEnvioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getServicioNotificacionEnvio)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)

        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchServicioNotificacionEnvioResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func uploadServicioNotificacionEnvio(params: UploadServicioNotificacionEnvioRequest, completion: @escaping (UploadServicioNotificacionEnvioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .uploadServicioNotificacionEnvio)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemNotificaciones = URLQueryItem(name: "vp_serv_notify", value: params.notificaciones)
        let queryItemCorreo = URLQueryItem(name: "vp_correo", value: params.correo)
        let queryItemTelefono = URLQueryItem(name: "vp_telefono", value: params.telefono)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemNotificaciones, queryItemCorreo, queryItemTelefono, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(UploadServicioNotificacionEnvioResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func marcarSeguimientoEnvio(params: SeguimientoEnvio.MarcarSeguimientoEnvio.Request, completion: @escaping (MarcarSeguimientoEnvioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .uploadSeguimientoEnvio)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemEstadoSeguimiento = URLQueryItem(name: "vp_ras_estado", value: params.estado)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemEstadoSeguimiento, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(MarcarSeguimientoEnvioResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchAgenciasUrbano(params: FetchAgenciasUrbanoRequest, completion: @escaping (FetchAgenciasUrbanoResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getAgenciasUrbano)
        
        let queryItemTipoAgencia = URLQueryItem(name: "vp_tipo_agencia", value: params.tipoAgencia)
        
        urlComponents.queryItems = [queryItemTipoAgencia]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchAgenciasUrbanoResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchEnviosEnSeguimiento(params: FetchEnviosEnSeguimientoRequest, completion: @escaping (FetchEnviosEnSeguimientoResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getEnviosEnSeguimiento)
        
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchEnviosEnSeguimientoResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchCentroNotificaciones(params: FetchCentroNotificacionesRequest, completion: @escaping (FetchCentroNotificacionesResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getCentroNotificaciones)
        
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchCentroNotificacionesResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func uploadRegistroUsuario(params: UploadRegistroUsuarioRequest, completion: @escaping (UploadRegistroUsuarioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .registerUser)
        
        let queryItemUserSessionIDOfPlatform = URLQueryItem(name: "vp_id_rrss", value: params.userSessionIDOfPlatform)
        let queryItemUserSessionPlatform = URLQueryItem(name: "vp_tip_rrss", value: params.userSessionPlatform)
        let queryItemUserSessionFullName = URLQueryItem(name: "vp_nombre", value: params.userSessionFullName)
        let queryItemUserSessionEmail = URLQueryItem(name: "vp_email", value: params.userSessionEmail)
        let queryItemUserSessionPhotoURL = URLQueryItem(name: "vp_url_foto", value: params.userSessionPhotoURL)
        let queryItemUserSessionPassword = URLQueryItem(name: "vp_passwd", value: params.userSessionPassword)
        let queryItemNameDevice = URLQueryItem(name: "vp_device", value: params.nameDevice)
        let queryItemNameOS = URLQueryItem(name: "vp_so", value: params.nameOS)
        let queryItemVersionOS = URLQueryItem(name: "vp_so_vrs", value: params.versionOS)
        let queryItemFcmToken = URLQueryItem(name: "vp_fcm_token", value: params.fcmToken)
        
        urlComponents.queryItems = [queryItemUserSessionIDOfPlatform, queryItemUserSessionPlatform, queryItemUserSessionFullName,
                                    queryItemUserSessionEmail, queryItemUserSessionPhotoURL, queryItemUserSessionPassword,
                                    queryItemNameDevice, queryItemNameOS, queryItemVersionOS, queryItemFcmToken]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(UploadRegistroUsuarioResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func getDataReprogramacion(params: FetchDataReprogramacionRequest, completion: @escaping (FetchDataReprogramacionResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getDataReprogramacion)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchDataReprogramacionResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchDistritos(params: FetchDistritosRequest, completion: @escaping (FetchDistritosResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .searchDistritos)
        
        let queryItemQuery = URLQueryItem(name: "vp_query", value: params.query)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemQuery, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchDistritosResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchFechasAgendarVisita(params: FetchFechasAgendarVisitaRequest, completion: @escaping (FetchFechasAgendarVisitaResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getFechasEntregaReprogramacion)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemMotID = URLQueryItem(name: "vp_mot_id", value: params.motID)
        let queryItemIDAge = URLQueryItem(name: "vp_id_age", value: params.idAge)
        let queryItemIDLocalidad = URLQueryItem(name: "vp_id_localidad", value: params.idLocalidad)
        let queryItemIDServicio = URLQueryItem(name: "vp_id_servicio", value: params.idTipoServicio)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemMotID, queryItemIDAge, queryItemIDLocalidad, queryItemIDServicio, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchFechasAgendarVisitaResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchHorariosAgendarVisita(params: FetchHorariosAgendarVisitaRequest, completion: @escaping (FetchHorariosAgendarVisitaResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getHorariosEntregaReprogramacion)
        
        let queryItemIDLocalidad = URLQueryItem(name: "vp_id_localidad", value: params.idLocalidad)
        let queryItemFechaVisita = URLQueryItem(name: "vp_fecha", value: params.fechaVisita)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemIDLocalidad, queryItemFechaVisita, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchHorariosAgendarVisitaResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func uploadAgendarVisita(params: UploadAgendarVisitaRequest, completion: @escaping (UploadAgendarVisitaResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .uploadReprogramacionVisita)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemIDMotivo = URLQueryItem(name: "vp_mot_id", value: params.idMotivo)
        let queryItemIDDireccion = URLQueryItem(name: "vp_dir_id", value: params.idDireccion)
        let queryItemIDCiudad = URLQueryItem(name: "vp_ciu_id", value: params.idCiudad)
        let queryItemDireccionEntrega = URLQueryItem(name: "vp_dir_entrega", value: params.direccionEntrega)
        let queryItemTransversal = URLQueryItem(name: "vp_transversal", value: params.transversal)
        let queryItemNroPuerta = URLQueryItem(name: "vp_num_puerta", value: params.nroPuerta)
        let queryItemNroInterior = URLQueryItem(name: "vp_num_interior", value: params.nroInterior)
        let queryItemReferencia = URLQueryItem(name: "vp_referencia", value: params.referencia)
        let queryItemLatitude = URLQueryItem(name: "vp_gps_x", value: params.latitude)
        let queryItemLongitude = URLQueryItem(name: "vp_gps_y", value: params.longitude)
        let queryItemFechaVisita = URLQueryItem(name: "vp_fecha_visita", value: params.fechaVisita)
        let queryItemIDHora = URLQueryItem(name: "vp_hora_id", value: params.idHora)
        let queryItemNombreAutorizado = URLQueryItem(name: "vp_nom_autorizado", value: params.nombreAutorizado)
        let queryItemDNIAutorizado = URLQueryItem(name: "vp_dni_autorizado", value: params.dniAutorizado)
        let queryItemEstadoNotifyLD = URLQueryItem(name: "vp_notify_ld", value: params.estadoNotifyLD)
        let queryItemEstadoNotifyDL = URLQueryItem(name: "vp_notify_dl", value: params.estadoNotifyDL)
        let queryItemEstadoNotifyCA = URLQueryItem(name: "vp_notify_ca", value: params.estadoNotifyCA)
        let queryItemTelefono = URLQueryItem(name: "vp_telefono", value: params.telefono)
        let queryItemCorreo = URLQueryItem(name: "vp_correo", value: params.correo)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUsuario = URLQueryItem(name: "vp_usu_id", value: params.idUsuario)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUser)
        
        urlComponents.queryItems = [queryItemGuia, queryItemIDMotivo, queryItemIDDireccion,
                                    queryItemIDCiudad, queryItemDireccionEntrega, queryItemTransversal,
                                    queryItemNroPuerta, queryItemNroInterior, queryItemReferencia,
                                    queryItemLatitude, queryItemLongitude, queryItemFechaVisita,
                                    queryItemIDHora, queryItemNombreAutorizado, queryItemDNIAutorizado,
                                    queryItemEstadoNotifyLD, queryItemEstadoNotifyDL, queryItemEstadoNotifyCA,
                                    queryItemTelefono, queryItemCorreo, queryItemLineaNegocio,
                                    queryItemIdUsuario, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(UploadAgendarVisitaResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func getDetalleReprogramacionVisita(params: FetchDetalleReprogramacionVisitaRequest, completion: @escaping (FetchDetalleReprogramacionVisitaResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getDetalleReprogramacionVisita)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchDetalleReprogramacionVisitaResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func getAgenciasReprogramacion(params: FetchAgenciasReprogramacionRequest, completion: @escaping (FetchAgenciasReprogramacionResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getAgenciasReprogramacion)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchAgenciasReprogramacionResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func getDetalleCalificacionServicio(params: FetchDetalleCalificacionServicioRequest, completion: @escaping (FetchDetalleCalificacionServicioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getDetalleCalificacionServicio)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchDetalleCalificacionServicioResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func uploadCalificacionServicio(params: UploadCalificacionServicioRequest, completion: @escaping (UploadCalificacionServicioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .uploadCalificarServicio)
        
        let queryItemGuia = URLQueryItem(name: "vp_gui_numero", value: params.guiNumero)
        let queryItemEstrellas = URLQueryItem(name: "vp_estrellas", value: params.estrellas)
        let queryItemComentario = URLQueryItem(name: "vp_comentarios", value: params.comentario)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemEstrellas, queryItemComentario, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(UploadCalificacionServicioResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func getGPSCourier(params: FetchGPSCourierRequest, completion: @escaping (FetchGPSCourierResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getGPSUnidadETracking)
        
        let queryItemGuia = URLQueryItem(name: "vp_guia", value: params.guiNumero)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemGuia, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let mimeType = response?.mimeType,
                mimeType == "application/json" else {
                    print("ERROR 1")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchGPSCourierResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func getGoogleDirections(params: GoogleDirectionsRequest, completion: @escaping (GoogleDirectionsResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .googleDirections)
        
        let queryItemOrigins = URLQueryItem(name: "origin", value: params.origin)
        let queryItemDestination = URLQueryItem(name: "destination", value: params.destination)
        
        urlComponents.queryItems = [queryItemOrigins, queryItemDestination]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(GoogleDirectionsResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchDepartamentos(params: FetchDepartamentosRequest, completion: @escaping (FetchDepartamentosResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .getDepartamentos)
        
        let queryItemID = URLQueryItem(name: "vp_id", value: params.id)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemID, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchDepartamentosResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func fetchDistritosPorDepartamento(params: FetchDistritosPorDepartamentoRequest, completion: @escaping (FetchDistritosPorDepartamentoResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .searchDistritosV3)
        
        let queryItemQuery = URLQueryItem(name: "vp_query", value: params.query)
        let queryItemIdDepartamento = URLQueryItem(name: "vp_id_dep", value: params.idDepartamento)
        let queryItemLineaNegocio = URLQueryItem(name: "vp_linea_negocio", value: params.lineaNegocio)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemQuery, queryItemIdDepartamento, queryItemLineaNegocio, queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchDistritosPorDepartamentoResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
    
    static func cotizarEnvio(params: FetchCotizarEnvioRequest, completion: @escaping (FetchCotizarEnvioResponse?, String?) -> Void) {
        let session = URLSession.shared
        
        var urlComponents = NetworkManager.shared().getURL(restPath: .cotizarEnvio)
        
        let queryItemIdCiudadOrigen = URLQueryItem(name: "vp_origen_ciu_id", value: params.idCiudadOrigen)
        let queryItemIdCiudadDestino = URLQueryItem(name: "vp_destino_ciu_id", value: params.idCiudadDestino)
        let queryItemTipoProducto = URLQueryItem(name: "vp_tipo_envio", value: params.tipoProducto)
        let queryItemPesoPaquete = URLQueryItem(name: "vp_peso", value: params.pesoPaquete)
        let queryItemAnchoPaquete = URLQueryItem(name: "vp_ancho", value: params.anchoPaquete)
        let queryItemAltoPaquete = URLQueryItem(name: "vp_alto", value: params.altoPaquete)
        let queryItemLargoPaquete = URLQueryItem(name: "vp_largo", value: params.largoPaquete)
        let queryItemValorDeclarado = URLQueryItem(name: "vp_valor_declarado", value: params.valorDeclarado)
        let queryItemIdUser = URLQueryItem(name: "vp_id_user", value: params.idUsuario)
        
        urlComponents.queryItems = [queryItemIdCiudadOrigen, queryItemIdCiudadDestino, queryItemTipoProducto, queryItemPesoPaquete,
                                    queryItemAnchoPaquete, queryItemAltoPaquete, queryItemLargoPaquete, queryItemValorDeclarado,
                                    queryItemIdUser]
        
        guard let url = urlComponents.url else {
            print("invalid URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "GET"
        
        print(urlComponents.url!)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    print("ERROR 2")
                    completion(nil, "Hubo un error y no se pudo procesar la solicitud.\nPor favor, inténtalo de nuevo.")
                    return
            }
            
            if let responseData = data {
                do {
                    let decodeBaseResponse = try JSONDecoder().decode(FetchCotizarEnvioResponse.self, from: responseData)
                    completion(decodeBaseResponse, nil)
                } catch let er {
                    completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
                }
            } else {
                completion(nil, "Ocurrió un error al procesar los datos recibidos.\nPor favor, inténtalo de nuevo.")
            }
            
        }
        task.resume()
    }
}
