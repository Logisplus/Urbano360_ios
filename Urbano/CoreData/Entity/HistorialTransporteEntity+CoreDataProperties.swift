//
//  HistorialTransporteEntity+CoreDataProperties.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//
//

import Foundation
import CoreData


extension HistorialTransporteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistorialTransporteEntity> {
        return NSFetchRequest<HistorialTransporteEntity>(entityName: "HistorialTransporteEntity")
    }

    @NSManaged public var idVisita: String?
    @NSManaged public var idCHK: String?
    @NSManaged public var codigoCHK: String?
    @NSManaged public var descripcionCHK: String?
    @NSManaged public var motivoMovimiento: String?
    @NSManaged public var descripcionMovimiento: String?
    @NSManaged public var numVisita: String?
    @NSManaged public var fecha: String?
    @NSManaged public var hora: String?
    @NSManaged public var gpsLatitudeMovimiento: String?
    @NSManaged public var gpsLongitudeMovimiento: String?
    @NSManaged public var eTracking: ETrackingEntity?

}
