//
//  DetalleVisitaTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 16/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MapKit

protocol DetalleVisitaTableViewCellDelegate {
    func didSelectItemAt(indexPath: IndexPath)
}

class DetalleVisitaTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var boxDetalleVisitaView: UIView!
    @IBOutlet weak var boxRecibidoPorView: UIView!
    @IBOutlet weak var boxDocIdentificacionView: UIView!
    @IBOutlet weak var boxImagenesView: UIView!
    @IBOutlet weak var boxUbicacionView: UIView!
    @IBOutlet weak var boxNoHayImagenesView: UIView!
    @IBOutlet weak var boxNoHayUbicacionView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var estadoVisitaLabel: UILabel!
    @IBOutlet weak var totalVisitaLabel: UILabel!
    @IBOutlet weak var fechaHoraLabel: UILabel!
    @IBOutlet weak var recibidoPorLabel: UILabel!
    @IBOutlet weak var docIdentificacionLabel: UILabel!
    @IBOutlet weak var comentariosLabel: UILabel!
    @IBOutlet weak var fotosCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var totalFotos: Int = 0
    
    var fotos: [FetchEnvioResponse.Data.HistorialTransporte.FotosVisita] = []
    
    var height : CGFloat!
    
    var constraintHeight: NSLayoutConstraint?
    
    var delegate: DetalleVisitaTableViewCellDelegate?
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.5, bottom: 0.0, right: 0.0)
    
    var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 3
            let itemWidth = (self.fotosCollectionView.frame.width - (numberOfColumns - 1)) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    var pin: PinAnnotation?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        addShadowWithRoundedCorners(view: boxDetalleVisitaView)
        fotosCollectionView.delegate = self
        fotosCollectionView.dataSource = self
        fotosCollectionView.register(UINib(nibName: "FotoVisitaCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "fotoVisitaCell")
        let layout = fotosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        layout.itemSize = itemSize
        height = fotosCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        mapView.delegate = self
        
        /*let l = NSLayoutDimension()
        l.constraint(equalToConstant: 100)
        
        NSLayoutConstraint.activate([
            fotosCollectionView.heightAnchor.constraint(equalTo: l, multiplier: 1)
            ])*/
        
        //fotosCollectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
    }
    
    /*override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let newHeight : CGFloat = self.fotosCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        var frame : CGRect! = self.fotosCollectionView.frame
        frame.size.height = newHeight
        
        self.fotosCollectionView.frame = frame
    }*/

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fotoVisitaCell", for: indexPath) as! FotoVisitaCollectionViewCell
    
        let url = URL(string: fotos[indexPath.row].img_path)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                if let _ = data {
                    cell.imageView.image = UIImage(data: data!)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        /*let vc=ImagePreviewVC()
        vc.imgArray = self.imageArray
        vc.passedContentOffset = indexPath
        self.navigationController?.pushViewController(vc, animated: true)*/
        
        delegate!.didSelectItemAt(indexPath: indexPath)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if anView == nil {
            anView?.annotation = annotation
        } else {
            if let _ = annotation as? PinAnnotation {
                /*if anAnnotation.custom_image {
                 let reuseId = "custom_image"
                 anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                 anView.image = UIImage(named:"custom_image")
                 }
                 else {*/
                let reuseId = "pin"
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView.pinTintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
                anView = pinView
                //}
            }
            //anView.canShowCallout = false
        }
        
        return anView
    }
    
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: pin, reuseIdentifier: "pin")
        annotationView.backgroundColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
        annotationView.image = UIImage(named: "ic_account_25pt")
        let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        annotationView.transform = transform
        return annotationView
    }*/
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * 4
        let availableWidth = boxImagenesView.frame.width - paddingSpace
        let widthPerItem  = availableWidth/3
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }*/
    
    /*func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        } else {
            annotationView?.annotation = annotation
        }
        
        if let annotation = annotation as? MyPointAnnotation {
            annotationView?.pinTintColor = annotation.pinTintColor
        }
        
        return annotationView
    }*/
    
    func viewSetup(eTracking: FetchEnvioResponse.Data.ETracking, movimientoGuia: FetchEnvioResponse.Data.HistorialTransporte) {
        self.estadoVisitaLabel.text = "Estado: \(movimientoGuia.motivo_movimiento.capitalized)"
        self.totalVisitaLabel.text = movimientoGuia.nro_visita
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date = "\(movimientoGuia.fecha) \(movimientoGuia.hora)"
        if let date = dateFormatter.date(from: date) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "dd"
            let day = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "EEEE"
            let dayName = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "MMMM"
            let monthName = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "yyyy"
            let year = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "h:mm a"
            let hour = newDateFormatter.string(from: date)
            self.fechaHoraLabel.text = "\(dayName.capitalized), \(day) de \(monthName.capitalized) del \(year) - \(hour)"
        } else {
            self.fechaHoraLabel.text = "No definido"
        }
        
        if let idCHK = Int(movimientoGuia.chk_id) {
            if idCHK == Constant.CHKControl.ENTREGADO {
                self.recibidoPorLabel.text = eTracking.nom_destinatario_entrega
                self.docIdentificacionLabel.text = eTracking.dni_destinatario_entrega
            } else if idCHK == Constant.CHKControl.NO_ENTREGADO {
                stackView.removeArrangedSubview(boxRecibidoPorView)
                stackView.removeArrangedSubview(boxDocIdentificacionView)
                boxRecibidoPorView.removeFromSuperview()
                boxDocIdentificacionView.removeFromSuperview()
            }
        }
        
        comentariosLabel.text = eTracking.comentarios
        
        if movimientoGuia.fotosVisita.count > 0 {
            print("TOTAL FOTOS: \(movimientoGuia.fotosVisita.count)")
            totalFotos = movimientoGuia.fotosVisita.count
            fotos = movimientoGuia.fotosVisita
            fotosCollectionView.reloadData()
            
            let columns: Double = Double(Double(totalFotos) / 3.0).rounded(.up)
            //let spaceVertical: Double = (columns - 1) * 10
            //let height: CGFloat = CGFloat(columns * 100.0 + spaceVertical)
            let spaceVertical: CGFloat = CGFloat(columns - 1.0)
            
            let height: CGFloat = CGFloat(CGFloat(columns) * itemSize.height + spaceVertical)
            
            let constraintHeight = NSLayoutConstraint(
                item: fotosCollectionView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: height
            )
            
            fotosCollectionView.addConstraint(constraintHeight)
            
            stackView.removeArrangedSubview(boxNoHayImagenesView)
            boxNoHayImagenesView.removeFromSuperview()
        } else {
            stackView.removeArrangedSubview(boxImagenesView)
            boxImagenesView.removeFromSuperview()
        }
        
        if let x = Double(movimientoGuia.gps_px), let y = Double(movimientoGuia.gps_py), (x != 0 && y != 0) {
            stackView.removeArrangedSubview(boxNoHayUbicacionView)
            boxNoHayUbicacionView.removeFromSuperview()
            let location = CLLocationCoordinate2DMake(x, y)
            pin = PinAnnotation(title: "", subtitle: "", coordinate: location)
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(location, 1000, 1000), animated: true)
            mapView.addAnnotation(pin!)
            
            /*let hellox = MyPointAnnotation()
            hellox.coordinate = location
            hellox.pinTintColor = .blue
            
            mapView.addAnnotation(hellox)*/
        } else {
            stackView.removeArrangedSubview(boxUbicacionView)
            boxUbicacionView.removeFromSuperview()
        }
        
    }
    
    func addShadowWithRoundedCorners(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 15)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 15
    }

}

class MyPointAnnotation : MKPointAnnotation {
    var pinTintColor: UIColor?
}
