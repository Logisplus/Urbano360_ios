//
//  Constant.swift
//  Urbano
//
//  Created by Mick VE on 12/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct Constant {
    
    struct CHKControl {
        static let SOLICITUD_DE_SERVICIO   : Int = 1
        static let SALIO_A_RUTA            : Int = 6
        static let ENTREGADO               : Int = 9
        static let NO_ENTREGADO            : Int = 7
        static let DEVOLUCION              : Int = 10
        static let CLIENTE_VISITADO        : Int = 74
    }
    
    enum URLPoliticas: String {
        case Chile = "https://app.urbanoexpress.cl/documentos/TerminosYCondiciones/CL/"
        case Ecuador = "https://app.urbano.com.ec/documentos/TerminosYCondiciones/EC/"
        case Peru = "https://app.urbano.com.pe/documentos/TerminosYCondiciones/PE/"
    }
    
    struct NotificationName {
        static let UserDidLogIn: NSNotification.Name = NSNotification.Name(rawValue: "UserDidLogInNotification")
        static let UserDidLogOut: NSNotification.Name = NSNotification.Name(rawValue: "UserDidLogOutNotification")
    }
    
}
