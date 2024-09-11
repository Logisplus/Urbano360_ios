//
//  ResgistrarUsuarioModels.swift
//  Urbano
//
//  Created by Mick VE on 20/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

struct RegistrarUsuario {
    struct UploadRegistroUsuario {
        struct Request {
            var userSessionIDOfPlatform: String
            var userSessionPlatform: String
            var userSessionFullName: String
            var userSessionEmail: String
            var userSessionPhotoURL: String
            var userSessionPassword: String
            var nameDevice: String
            var nameOS: String
            var versionOS: String
            var fcmToken: String
        }
        
        struct Response: Decodable {
            let success: Bool
            let msg_error: String
            let data: [UserData]
            let code_error: String
            
            struct UserData: Decodable {
                let error_sql: String
                let error_info: String
                let user_id: String
            }
        }
    }
}

typealias UploadRegistroUsuarioRequest = RegistrarUsuario.UploadRegistroUsuario.Request
typealias UploadRegistroUsuarioResponse = RegistrarUsuario.UploadRegistroUsuario.Response
