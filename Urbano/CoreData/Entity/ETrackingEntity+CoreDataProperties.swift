//
//  ETrackingEntity+CoreDataProperties.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//
//

import Foundation
import CoreData

extension ETrackingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ETrackingEntity> {
        return NSFetchRequest<ETrackingEntity>(entityName: "ETrackingEntity")
    }

    @NSManaged public var guiaElectronica: String?
    @NSManaged public var idGuia: String?
    @NSManaged public var codigoRastreo: String?
    @NSManaged public var idCHK: String?
    @NSManaged public var codigoCHK: String?
    @NSManaged public var descripcionCHK: String?
    @NSManaged public var descripcionMotivo: String?
    @NSManaged public var idVisita: String?
    @NSManaged public var numVisita: String?
    @NSManaged public var fechaAO: String?
    @NSManaged public var fechaCHK: String?
    @NSManaged public var remite: String?
    @NSManaged public var origen: String?
    @NSManaged public var destino: String?
    @NSManaged public var nombreDestinatario: String?
    @NSManaged public var emailDestinatario: String?
    @NSManaged public var telefonosDestinatario: String?
    @NSManaged public var idDireccionEntrega: String?
    @NSManaged public var direccionEntrega: String?
    @NSManaged public var referenciaDireccionEntrega: String?
    @NSManaged public var localidadEntrega: String?
    @NSManaged public var direccionEntregaGPSLatitude: String?
    @NSManaged public var direccionEntregaGPSLongitude: String?
    @NSManaged public var horaLlegadaAproximada: String?
    @NSManaged public var importePorCobrar: String?
    @NSManaged public var metodoPagoImporte: String?
    @NSManaged public var descripcionPaquete: String?
    @NSManaged public var totalPiezas: String?
    @NSManaged public var totalPeso: String?
    @NSManaged public var unidadPlaca: String?
    @NSManaged public var unidadTipo: String?
    @NSManaged public var nombreCourier: String?
    @NSManaged public var unidadGPSLatitude: String?
    @NSManaged public var unidadGPSLongitude: String?
    @NSManaged public var guiasEntregaPendiente: String?
    @NSManaged public var horarioEntrega: String?
    @NSManaged public var nombreDestinatarioEntrega: String?
    @NSManaged public var dniDestinatarioEntrega: String?
    @NSManaged public var comentarioGestionGuia: String?
    @NSManaged public var urlLogoRemitente: String?
    @NSManaged public var googleOriginLatitude: String?
    @NSManaged public var googleOriginLongitude: String?
    @NSManaged public var googleDistance: String?
    @NSManaged public var googleDuration: String?
    @NSManaged public var googleOverviewPolyline: String?
    @NSManaged public var servicioReprogramacion: Int16
    @NSManaged public var reprogramacionPendiente: Int16
    @NSManaged public var servicioOverNight: Int16
    @NSManaged public var servicioWeekEnd: Int16
    @NSManaged public var tipoSeguimiento: Int16
    @NSManaged public var lineaNegocio: String?
    @NSManaged public var historialTransporte: NSSet?
    @NSManaged public var fotosVisita: NSSet?

}

// MARK: Generated accessors for historialTransporte
extension ETrackingEntity {

    @objc(addHistorialTransporteObject:)
    @NSManaged public func addToHistorialTransporte(_ value: HistorialTransporteEntity)

    @objc(removeHistorialTransporteObject:)
    @NSManaged public func removeFromHistorialTransporte(_ value: HistorialTransporteEntity)

    @objc(addHistorialTransporte:)
    @NSManaged public func addToHistorialTransporte(_ values: NSSet)

    @objc(removeHistorialTransporte:)
    @NSManaged public func removeFromHistorialTransporte(_ values: NSSet)

}

// MARK: Generated accessors for fotosVisita
extension ETrackingEntity {

    @objc(addFotosVisitaObject:)
    @NSManaged public func addToFotosVisita(_ value: FotosVisitaEntity)

    @objc(removeFotosVisitaObject:)
    @NSManaged public func removeFromFotosVisita(_ value: FotosVisitaEntity)

    @objc(addFotosVisita:)
    @NSManaged public func addToFotosVisita(_ values: NSSet)

    @objc(removeFotosVisita:)
    @NSManaged public func removeFromFotosVisita(_ values: NSSet)

}
