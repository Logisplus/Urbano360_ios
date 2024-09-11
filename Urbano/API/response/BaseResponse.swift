//
//  BaseResponse.swift
//  Urbano
//
//  Created by Mick VE on 2/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

class BaseResponse: Decodable {
    let success: Bool
    let msg_error: String
    //let data: []
    let code_error: String
}
