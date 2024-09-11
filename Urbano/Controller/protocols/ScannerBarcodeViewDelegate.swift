//
//  ScannerBarcodeViewDelegate.swift
//  Urbano
//
//  Created by Mick VE on 23/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

protocol ScannerBarcodeViewDelegate {
    func barcodeDidRead(code: String)
}
