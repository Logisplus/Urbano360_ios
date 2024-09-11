//
//  DetalleAgenciaTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 6/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

class DetalleAgenciaTableViewCell: UITableViewCell, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var boxDetalleAgenciaView: UIView!
    @IBOutlet weak var boxDireccionView: UIView!
    @IBOutlet weak var boxTelefonoView: UIView!
    @IBOutlet weak var boxContactoView: UIView!
    @IBOutlet weak var boxSitioWebView: UIView!
    @IBOutlet weak var nombreAgenciaLabel: UILabel!
    @IBOutlet weak var direccionLabel: UILabel!
    @IBOutlet weak var telefonoLabel: UILabel!
    @IBOutlet weak var contactoLabel: UILabel!
    @IBOutlet weak var sitioWebLabel: UILabel!
    
    var agencia: Localizanos.FetchAgenciasUrbano.Response.Agencias?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        addShadowWithRoundedCorners(view: boxDetalleAgenciaView)
        setupTapGestureToViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupDetalleAgencia(agencia: Localizanos.FetchAgenciasUrbano.Response.Agencias) {
        self.agencia = agencia
        nombreAgenciaLabel.text = agencia.prov_descri.capitalized
        direccionLabel.text = agencia.dir_calle.capitalized
    }
    
    func setupTapGestureToViews() {
        var tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.boxDireccionDidTap(_:)))
        self.boxDireccionView.addGestureRecognizer(tabGesture)
        
        tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.boxTelefonoDidTap(_:)))
        self.boxTelefonoView.addGestureRecognizer(tabGesture)
        
        tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.boxContactoDidTap(_:)))
        self.boxContactoView.addGestureRecognizer(tabGesture)
        
        tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.boxSitioWebDidTap(_:)))
        self.boxSitioWebView.addGestureRecognizer(tabGesture)
    }
    
    func addShadowWithRoundedCorners(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 15)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 15
    }
    
    @objc func boxDireccionDidTap(_ sender: UITapGestureRecognizer) {
        let coordinate = CLLocationCoordinate2DMake(Double(self.agencia!.x)!, Double(self.agencia!.y)!)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = agencia!.prov_descri.capitalized
        mapItem.phoneNumber = "(511) 4151800"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
        // Open and show coordinate
        //let url = "http://maps.apple.com/maps?saddr=\(self.agencia!.x),\(self.agencia!.y)"
        //UIApplication.shared.open(URL(string:url)!)
        
        // Navigate from one coordinate to another
        //let url = "http://maps.apple.com/maps?saddr=\(from.latitude),\(from.longitude)&daddr=\(to.latitude),\(to.longitude)"
        //let url = "http://maps.apple.com/maps?saddr=&daddr=\(self.agencia!.x),\(self.agencia!.y)"
        //UIApplication.shared.open(URL(string:url)!)
        
        /*let coordinate = CLLocationCoordinate2DMake(Double(self.agencia!.x)!, Double(self.agencia!.y)!)
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.01, 0.02))
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
        mapItem.name = agencia!.prov_descri.capitalized
        mapItem.openInMaps(launchOptions: options)*/
        
        /*//let targetURL = URL(string: "http://maps.apple.com/?q=cupertino")!
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            let targetURL = URL(string: "comgooglemaps://?q=cupertino")!
            UIApplication.shared.open(targetURL)
        } else {
            print("NO HAY GOOGLE MAPS")
        }*/
    }
    
    @objc func boxTelefonoDidTap(_ sender: UITapGestureRecognizer) {
        guard let number = URL(string: "tel://5114151800") else {
            return
        }
        UIApplication.shared.open(number)
    }
    
    @objc func boxContactoDidTap(_ sender: UITapGestureRecognizer) {
        /*if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mickhve@gmail.com"])
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            
            delegate!.sendMail(mail: mail)
        } else {
            // show failure alert
            print("EMAIL FAIL")
        }*/
        let url = URL(string: "mailto:comercial@urbano.com.pe")
        UIApplication.shared.open(url!)
    }
    
    /*func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
     controller.dismiss(animated: true)
     }*/
    
    @objc func boxSitioWebDidTap(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "http://www.urbanoexpress.com/")
        UIApplication.shared.open(url!)
    }

}
