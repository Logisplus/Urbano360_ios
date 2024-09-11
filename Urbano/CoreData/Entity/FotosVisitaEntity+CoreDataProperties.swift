//
//  FotosVisitaEntity+CoreDataProperties.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//
//

import Foundation
import CoreData


extension FotosVisitaEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FotosVisitaEntity> {
        return NSFetchRequest<FotosVisitaEntity>(entityName: "FotosVisitaEntity")
    }

    @NSManaged public var idVisita: String?
    @NSManaged public var idImagen: String?
    @NSManaged public var gpsLatitude: String?
    @NSManaged public var gpsLongitude: String?
    @NSManaged public var imgTipo: String?
    @NSManaged public var imgFechaHora: String?
    @NSManaged public var imgUrl: String?
    @NSManaged public var eTracking: ETrackingEntity?

}
