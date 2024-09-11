//
//  RastrearEnvioViewController.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class RastrearEnvioViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var boxEstadoGuia: UIView!
    @IBOutlet weak var boxContentEstadoGuia: UIView!
    @IBOutlet weak var boxDetalleEstadoGuia: UIView!
    @IBOutlet weak var boxGuia: UIView!
    @IBOutlet weak var boxRemitente: UIView!
    @IBOutlet weak var boxDetalleEnvio: UIView!
    @IBOutlet weak var boxContentImportePorCobrar: UIView!
    @IBOutlet weak var boxContenidoEnvio: UIView!
    @IBOutlet weak var boxSubDetalleEstadoGuiaStackView: UIStackView!
    @IBOutlet weak var boxFotosVisitaEstadoGuia: UIView!
    
    @IBOutlet weak var estadoGuiaLabel: UILabel!
    @IBOutlet weak var descripcionEstadoGuiaLabel: UILabel!
    @IBOutlet weak var truckEstadoGuiaImage: UIImageView!
    @IBOutlet weak var fotoVisitaImage: UIImageView!
    @IBOutlet weak var totalFotoVisitaLabel: UILabel!
    @IBOutlet weak var subDetalleEstadoGuiaTopLabel: UILabel!
    @IBOutlet weak var subDetalleEstadoGuiaBottomLabel: UILabel!
    @IBOutlet weak var guiaElectronicaLabel: UILabel!
    @IBOutlet weak var remitenteLabel: UILabel!
    @IBOutlet weak var origenLabel: UILabel!
    @IBOutlet weak var destinoLabel: UILabel!
    @IBOutlet weak var fechaAdmitidoLabel: UILabel!
    @IBOutlet weak var importePorCobrarImage: UIImageView!
    @IBOutlet weak var tituloImportePorCobrarLabel: UILabel!
    @IBOutlet weak var importePorCobrarLabel: UILabel!
    @IBOutlet weak var destinatarioLabel: UILabel!
    @IBOutlet weak var direccionEntregaLabel: UILabel!
    @IBOutlet weak var descripcionContenidoLabel: UILabel!
    @IBOutlet weak var totalPiezasLabel: UILabel!
    @IBOutlet weak var pesoContenidoLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackViewContentDetalleEnvio: UIStackView!
    @IBOutlet weak var stackViewContentRemitente: UIStackView!
    
    var activityIndicator: CustomViewController.ActivityIndicator?
    
    var searchGuia: String?
    
    var responseRastrearEnvio: FetchEnvioResponse?
    
    var isAlertsAlreadyShown = false // ReprogramacionVisitaAlert, ImportePorCobrarAlert
    
    var isVisibleCancelButton = false // Usado cuando se muestra desde una notificacion
    
    var isInitialized = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.edgesForExtendedLayout = .bottom
        //self.extendedLayoutIncludesOpaqueBars = true
        
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        
        /*var navigationBarAnimation = CATransition()
        navigationBarAnimation.duration = 5.0
        navigationBarAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        navigationBarAnimation.type = kCATransitionFade
        navigationBarAnimation.subtype = kCATransitionFade
        navigationBarAnimation.isRemovedOnCompletion = true
        self.navigationController?.navigationBar.layer.add(navigationBarAnimation, forKey: nil)*/
        
        
        
        /*self.navigationItem.title = "Gradiant Back Ground"
        let gradientLayer = CAGradientLayer()
         var updatedFrame = self.navigationController!.navigationBar.bounds
         updatedFrame.size.height += UIApplication.shared.statusBarFrame.size.height
         gradientLayer.frame = updatedFrame
         gradientLayer.colors = [UIColor.green.cgColor, UIColor.blue.cgColor] // start color and end color
         gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // Horizontal gradient start
         gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0) // Horizontal gradient end
         UIGraphicsBeginImageContext(gradientLayer.bounds.size)
         gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
         let image = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         self.navigationController!.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)*/
        
        setupViews()
        
        rastrearEnvio()
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard self.navigationController?.topViewController === self else {return}
        
        self.transitionCoordinator?.animate(alongsideTransition: { [weak self](context) in
            self?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }, completion: { (context) in })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard self.navigationController?.topViewController === self else {return}
        
        self.transitionCoordinator?.animate(alongsideTransition: { [weak self](context) in
            self?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self?.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }, completion: { (context) in })
    }*/
    
    /*override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.isTranslucent = false
        //self.navigationController?.navigationBar.backgroundColor = ColorPalette.Urbano.rojo
        //self.navigationController?.navigationBar.layer.backgroundColor = ColorPalette.Urbano.rojo.cgColor
    }*/
    
    /*func navigationController(_ navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
            if viewController == self {
                if !self.isInitialized {
                    var navigationBarAnimation = CATransition()
                    navigationBarAnimation.duration = 1.5
                    navigationBarAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                    navigationBarAnimation.type = kCATransitionFade
                    navigationBarAnimation.subtype = kCATransitionFade
                    navigationBarAnimation.isRemovedOnCompletion = true
                    self.navigationController?.navigationBar.layer.add(navigationBarAnimation, forKey: nil)
                            self.isInitialized = true;
                    }
            }
    }

    func navigationController(_ navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
            if viewController == self {
                if self.isInitialized {
                    self.navigationController?.navigationBar.layer.removeAllAnimations()
                }
            }
    }*/
    
    func setupViews() {
        setupNavigationItem()
        
        activityIndicator = CustomViewController.ActivityIndicator(view: self.view, navigationController: nil, tabBarController: nil)
        activityIndicator?.showActivityIndicator(withLabel: true, indicatorViewStyle: .gray)
        
        addShadowWithRoundedCorners(view: boxEstadoGuia)
        addCorners(view: boxContentEstadoGuia)
        
        addShadowWithRoundedCorners(view: boxGuia)
        addShadowWithRoundedCorners(view: boxRemitente)
        addShadowWithRoundedCorners(view: boxDetalleEnvio)
        addShadowWithRoundedCorners(view: boxContenidoEnvio)
        
        boxFotosVisitaEstadoGuia.clipsToBounds = true
        
        /*if #available(iOS 11.0, *) {
         let viewController = UIStoryboard(name: "GuiaSearch", bundle: nil).instantiateInitialViewController()
         let searchController = UISearchController(searchResultsController: viewController)
         searchController.searchBar.tintColor = UIColor.white
         searchController.searchBar.autocapitalizationType = .allCharacters
         searchController.searchBar.placeholder = "Ingresa tu código de rastreo"
         searchController.searchBar.delegate = self
         navigationItem.searchController = searchController
         self.definesPresentationContext = true;
         }*/
        
        let boxDetalleEstadoGuiaTap = UITapGestureRecognizer(target: self, action: #selector(self.boxDetalleEstadoGuiaTap(_:)))
        boxDetalleEstadoGuia.addGestureRecognizer(boxDetalleEstadoGuiaTap)
        
        let boxFotosVisitaEstadoGuiaTap = UITapGestureRecognizer(target: self, action: #selector(self.boxFotosVisitaEstadoGuiaTap(_:)))
        boxFotosVisitaEstadoGuia.addGestureRecognizer(boxFotosVisitaEstadoGuiaTap)
        
        let stackViewContentRemitenteTap = UITapGestureRecognizer(target: self, action: #selector(self.stackViewContentRemitenteDidTap(_:)))
        remitenteLabel.addGestureRecognizer(stackViewContentRemitenteTap)
        remitenteLabel.isUserInteractionEnabled = true
        
        if isVisibleCancelButton {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.cancelButtonDidTap(_:)))
        }
    }
    
    // MARK: - Request
    
    func rastrearEnvio() {
        let params = FetchEnvioRequest(guia: searchGuia!,
                                       lineaNegocio: "0",
                                       idUsuario: UserSession.getUserSessionID())
        
        API.rastrearEnvio(params: params) { (data, error) in
            if let _ = error {
                let alertController = UIAlertController(title: "Error al rastrear tu envío",
                                                        message: error,
                                                        preferredStyle: .alert)
                
                let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if let data = data {
                guard data.success else {
                    let alertController = UIAlertController(title: "Error al rastrear tu envío",
                                                            message: "No existe envío con esta guía.",
                                                            preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                self.processDataRastrearEnvio(data: data)
            }
        }
    }
    
    func processDataRastrearEnvio(data: FetchEnvioResponse) {
        self.responseRastrearEnvio = data
        
        self.registerSearchTrackingRecord(guia: data.data[0].eTracking.guia_texto)
        
        DispatchQueue.main.async {
            self.configBoxEstadoGuia(eTracking: data.data[0].eTracking)
            self.configBoxSubDetalleEstadoGuia(data: data.data[0])
            self.guiaElectronicaLabel.text = data.data[0].eTracking.guia_texto
            self.remitenteLabel.text = data.data[0].eTracking.remite
            self.origenLabel.text = data.data[0].eTracking.origen
            self.destinoLabel.text = data.data[0].eTracking.destino
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            if let date = dateFormatter.date(from: data.data[0].eTracking.fecha_ao) {
                let newDateFormatter = DateFormatter()
                newDateFormatter.dateFormat = "dd"
                let day = newDateFormatter.string(from: date)
                newDateFormatter.dateFormat = "EEEE"
                let dayName = newDateFormatter.string(from: date)
                newDateFormatter.dateFormat = "MMMM"
                let monthName = newDateFormatter.string(from: date)
                newDateFormatter.dateFormat = "yyyy"
                let year = newDateFormatter.string(from: date)
                self.fechaAdmitidoLabel.text = "\(dayName.capitalized), \(day) de \(monthName.capitalized) del \(year)"
            } else {
                self.fechaAdmitidoLabel.text = "Aun no recibimos tu envío"
            }
            
            self.configBoxImportePorCobrar(eTracking: data.data[0].eTracking)
            
            self.destinatarioLabel.text = data.data[0].eTracking.cliente
            
            if data.data[0].eTracking.referencia.isEmpty {
                self.direccionEntregaLabel.text = "\(data.data[0].eTracking.direccion) - \(data.data[0].eTracking.localidad)"
            } else {
                self.direccionEntregaLabel.text = "\(data.data[0].eTracking.direccion) - Ref. \(data.data[0].eTracking.referencia) - \(data.data[0].eTracking.localidad)"
            }
            
            self.descripcionContenidoLabel.text = data.data[0].eTracking.descripcion_paquete
            self.totalPiezasLabel.text = "\(data.data[0].eTracking.piezas) pieza(s)"
            self.pesoContenidoLabel.text = "\(data.data[0].eTracking.peso) kg"

            self.configButtonDetalleReprogramacion(estadoReprogramacion: data.data[0].eTracking.pend_agendamiento)
            
            if !self.isAlertsAlreadyShown {
                if let idCHK = Int(data.data[0].eTracking.pend_agendamiento), idCHK == 1 {
                    self.showDetalleReprogramacionAlert()
                } else if let idCHK = Int(data.data[0].eTracking.chk_id),
                    idCHK == Constant.CHKControl.SALIO_A_RUTA {
                    self.showImportePorCobrarAlert()
                }
            }
            
            self.activityIndicator?.stopActivityIndicator()
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollView.alpha = 1.0
            })
        }
    }
    
    func configBoxEstadoGuia(eTracking: FetchEnvioResponse.Data.ETracking) {
        let idCHK = Int(eTracking.chk_id)
        var descripcionEstadoGuia: String

        switch idCHK! {
            case Constant.CHKControl.SALIO_A_RUTA:
                self.truckEstadoGuiaImage.image = UIImage(named: "ic_truck_25pt")
                self.boxContentEstadoGuia.backgroundColor = PalleteColorUrbano.gris
                descripcionEstadoGuia = "Courier: \(eTracking.nom_courier.capitalized)"
            case Constant.CHKControl.ENTREGADO:
                self.truckEstadoGuiaImage.image = UIImage(named: "ic_truck_25pt")
                self.boxContentEstadoGuia.backgroundColor = PalleteColorUrbano.negro
                descripcionEstadoGuia = "Firma: \(eTracking.nom_destinatario_entrega) (DNI: \(eTracking.dni_destinatario_entrega))"
            case Constant.CHKControl.NO_ENTREGADO, Constant.CHKControl.DEVOLUCION:
                self.truckEstadoGuiaImage.image = UIImage(named: "ic_truck_black_25pt")
                self.boxContentEstadoGuia.backgroundColor = PalleteColorUrbano.rojo
                descripcionEstadoGuia = eTracking.mot_descripcion.capitalized
            default:
                self.truckEstadoGuiaImage.image = UIImage(named: "ic_truck_25pt")
                self.boxContentEstadoGuia.backgroundColor = PalleteColorUrbano.gris
                descripcionEstadoGuia = eTracking.mot_descripcion.capitalized
        }

        self.estadoGuiaLabel.text = eTracking.chk_descripcion.uppercased()
        self.descripcionEstadoGuiaLabel.text = descripcionEstadoGuia
    }
    
    func configBoxSubDetalleEstadoGuia(data: FetchEnvioResponse.Data) {
        let idCHK = Int(data.eTracking.chk_id)
        
        switch idCHK! {
        case Constant.CHKControl.SALIO_A_RUTA:
            self.boxFotosVisitaEstadoGuia.alpha = 0
            self.boxSubDetalleEstadoGuiaStackView.alpha = 1
            self.subDetalleEstadoGuiaTopLabel.text = ""
            self.subDetalleEstadoGuiaBottomLabel.text = data.eTracking.nro_visita
        case Constant.CHKControl.ENTREGADO, Constant.CHKControl.NO_ENTREGADO, Constant.CHKControl.DEVOLUCION:
            self.boxFotosVisitaEstadoGuia.alpha = 1
            self.boxSubDetalleEstadoGuiaStackView.alpha = 0
            var urlFoto: String?
            var totalFotos: Int?
            
            for historial in data.historialTransporte {
                if historial.id_visita == data.eTracking.id_visita {
                    if historial.fotosVisita.count > 0 {
                        urlFoto = historial.fotosVisita[0].img_path
                        totalFotos = historial.fotosVisita.count
                    } else {
                        print("Error al extraer la url de la foto de visita!!!")
                    }
                }
            }
            
            if let _ = urlFoto {
                self.totalFotoVisitaLabel.text = "+\(totalFotos!)"
                let url = URL(string: urlFoto!)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        if let _ = data {
                            self.fotoVisitaImage.image = UIImage(data: data!)
                        }
                    }
                }
            } else {
                self.totalFotoVisitaLabel.text = "+0"
            }
        default:
            self.boxFotosVisitaEstadoGuia.alpha = 0
            self.boxSubDetalleEstadoGuiaStackView.alpha = 1
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            if let date = dateFormatter.date(from: data.eTracking.fecha_chk) {
                let newDateFormatter = DateFormatter()
                newDateFormatter.dateFormat = "dd/MM/yyyy"
                let fecha = newDateFormatter.string(from: date)
                newDateFormatter.dateFormat = "h:mm a"
                let hora = newDateFormatter.string(from: date)
                self.subDetalleEstadoGuiaTopLabel.text = hora.uppercased()
                self.subDetalleEstadoGuiaBottomLabel.text = fecha
            } else {
                self.subDetalleEstadoGuiaTopLabel.text = "No"
                self.subDetalleEstadoGuiaBottomLabel.text = "Definido"
            }
        }
    }
    
    func configBoxImportePorCobrar(eTracking: FetchEnvioResponse.Data.ETracking) {
        if eTracking.cod_importe.isEmpty {
            if self.stackViewContentDetalleEnvio.arrangedSubviews.count == 5 {
                self.stackViewContentDetalleEnvio.removeArrangedSubview(self.boxContentImportePorCobrar)
                self.boxContentImportePorCobrar.removeFromSuperview()
            }
        } else {
            if self.stackViewContentDetalleEnvio.arrangedSubviews.count != 5 {
                self.view.addSubview(self.boxContentImportePorCobrar)
                self.stackViewContentDetalleEnvio.insertArrangedSubview(self.boxContentImportePorCobrar, at: 2)
            }
            
            if self.boxContentImportePorCobrar.gestureRecognizers?.count ?? 0 == 0 {
                let gestureTap = UITapGestureRecognizer(target: self, action: #selector(self.showImportePorCobrarAlert))
                self.boxContentImportePorCobrar.addGestureRecognizer(gestureTap)
            }
            
            self.importePorCobrarLabel.text = eTracking.cod_importe
            
            guard let idCHK = Int(eTracking.chk_id),
                let tipoCOD = Int(eTracking.cod_tipo) else {
                    self.tituloImportePorCobrarLabel.text = "Importe"
                    return
            }
            
            if idCHK == Constant.CHKControl.ENTREGADO {
                self.tituloImportePorCobrarLabel.text = "Valor pagado"
            } else {
                self.tituloImportePorCobrarLabel.text = "Valor a pagar"
            }
            
            if tipoCOD == 1 { // Efectivo
                self.importePorCobrarImage.image = UIImage(named: "ic_money_25pt")
            } else { // Tarjeta
                self.importePorCobrarImage.image = UIImage(named: "ic_credit_card_25pt")
            }
        }
    }
    
    @objc func showImportePorCobrarAlert() {
        self.isAlertsAlreadyShown = true
        if !responseRastrearEnvio!.data[0].eTracking.cod_importe.isEmpty {
            var title = "Valor a pagar"
            var message = "Hay un valor pendiente de \(responseRastrearEnvio!.data[0].eTracking.cod_importe) por pagar, recuerda tenerlo disponible al momento de recibir tu envío."
            
            if let idCHK = Int(responseRastrearEnvio!.data[0].eTracking.chk_id),
                idCHK == Constant.CHKControl.ENTREGADO {
                title = "Valor pagado"
                message = "Un valor de \(responseRastrearEnvio!.data[0].eTracking.cod_importe) fue pagado al momento de recibir tu envío."
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showDetalleReprogramacionAlert() {
        let alertController = UIAlertController(title: "Reprogramación de Visita",
                                                message: "Actualmente tienes una reprogramación de visita pendiente.",
                                                preferredStyle: .alert)
        
        let verAction = UIAlertAction(title: "Ver", style: .default) { (action:UIAlertAction) in
            self.reprogramarButtonDidTap()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (action:UIAlertAction) in
            self.showImportePorCobrarAlert()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(verAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func configButtonDetalleReprogramacion(estadoReprogramacion: String) {
        var buttons: [UIBarButtonItem] = []
        
        buttons.append(UIBarButtonItem(image: UIImage(named: "ic_nav_bar_dots_horizontal_25pt"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(self.moreActionsDidTap)))

        if let idCHK = Int(estadoReprogramacion), idCHK == 1 {
            buttons.append(UIBarButtonItem(image: UIImage(named: "ic_calendar_bar_button_25pt"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(reprogramarButtonDidTap)))
        }
        
        self.navigationItem.rightBarButtonItems = buttons
    }
    
    func setupNavigationItem() {
        self.navigationItem.largeTitleDisplayMode = .always
        
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        self.navigationItem.backBarButtonItem = backItem
    }
    
    func addShadowWithRoundedCorners(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 15)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 15
        //        view.layer.masksToBounds = false
    }
    
    func addCorners(view: UIView) {
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        // border
        //        boxEstadoGuia.layer.borderWidth = 1.0
        //        boxEstadoGuia.layer.borderColor = UIColor.black.cgColor
    }
    
    func addShadow(view: UIView) {
        // shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 15)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 15
        view.layer.masksToBounds = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToHistorialTransitoVC" {
            let vc = segue.destination as! HistorialTransitoTableViewController
            vc.responseRastrearEnvio = self.responseRastrearEnvio
        } else if segue.identifier == "segueFromRastrearEnvioToDetalleVisitaVC" {
            let vc = segue.destination as! DetalleVisitaTableViewController
            let eTracking = responseRastrearEnvio!.data[0].eTracking
            let movimientos = responseRastrearEnvio!.data[0].historialTransporte
            for movimiento in movimientos {
                if movimiento.id_visita == eTracking.id_visita {
                    vc.eTracking = eTracking
                    vc.movimientoGuia = movimiento
                }
            }
        } else if segue.identifier == "segueFromRastrearEnvioToDetalleReprogramacion" {
            let vc = segue.destination as! DetalleReprogramacionVisitaVC
            vc.guiaNumero = responseRastrearEnvio!.data[0].eTracking.guia
            vc.guiaElectronica = self.guiaElectronicaLabel.text
            vc.lineaNegocio = responseRastrearEnvio!.data[0].eTracking.linea_negocio
        } else if segue.identifier == "segueFromRastrearEnvioToMapaEnvio" {
            let vc = segue.destination as! MapaEnvioController
            vc.delegate = self
            vc.eTracking = responseRastrearEnvio!.data[0].eTracking
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func onCerrarAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Funciona")
    }
    
    @objc func moreActionsDidTap() {
        guard let _ = self.responseRastrearEnvio else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let historialAction = UIAlertAction(title: "Historial de tránsito", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "segueToHistorialTransitoVC", sender: nil)
        })
        
        let marcarSeguimientoAction = actionMarcarParaSeguimientoBuild()
        let notificacionesAction = actionConfigurarNotificacionesBuild()
        let reprogramarVisitaAction = setupReprogramarVisitaAction()
        
        let compartirAction = UIAlertAction(title: "Compartir envío...", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            let urlEnvio = "\(self.getEtrackingURL())\(self.responseRastrearEnvio!.data[0].eTracking.guia_texto)"
            let shareText = "Urbano 360®, la mejor manera de rastrear tus envíos con información en tiempo real.\n\n\(urlEnvio)"
            let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
            self.present(vc, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        historialAction.setValue(UIImage(named: "ic_clock_25pt"), forKey: "image")
        compartirAction.setValue(UIImage(named: "ic_action_25pt"), forKey: "image")
        //defaultAction.setValue(image?.withRenderingMode(.alwaysOriginal), forKey: "image")
        //defaultAction.setValue(PalleteColorUrbano.gris, forKey: "titleTextColor")
        
        alertController.addAction(compartirAction)
        if let _ = marcarSeguimientoAction {
            alertController.addAction(marcarSeguimientoAction!)
        }
        if let _ = notificacionesAction {
            alertController.addAction(notificacionesAction!)
        }
        if let _ = reprogramarVisitaAction {
            alertController.addAction(reprogramarVisitaAction!)
        }
        alertController.addAction(historialAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func reprogramarButtonDidTap() {
        performSegue(withIdentifier: "segueFromRastrearEnvioToDetalleReprogramacion", sender: nil)
    }
    
    func actionMarcarParaSeguimientoBuild() -> UIAlertAction? {
        guard let tipoSeguimiento = Int(responseRastrearEnvio!.data[0].eTracking.tipo_seguimiento) else {
                return nil
        }
        
        var titleAction: String = ""
        var estadoSeguimiento: String = ""
        
        switch tipoSeguimiento {
        case 0:
            titleAction = "Marcar para seguimiento"
            estadoSeguimiento = "1"
        case 1, 2:
            titleAction = "Quitar de seguimiento"
            estadoSeguimiento = "0"
        default:
            print("El tipo de seguimiento de la guia es desconocido")
            return nil
        }
        
        let action = UIAlertAction(title: titleAction, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if UserSession.isUserLogged() {
                let loadingViewController = LoadingViewController(message: "Loading...")
                self.present(loadingViewController, animated: true, completion: nil)
                
                let params = SeguimientoEnvio.MarcarSeguimientoEnvio.Request(guiNumero: self.responseRastrearEnvio!.data[0].eTracking.guia,
                                                                             estado: estadoSeguimiento,
                                                                             lineaNegocio: self.responseRastrearEnvio!.data[0].eTracking.linea_negocio,
                                                                             idUsuario: UserSession.getUserSessionID())
                
                API.marcarSeguimientoEnvio(params: params) { (data, error) in
                    DispatchQueue.main.async {
                        loadingViewController.dismiss(animated: true, completion: {
                            if let _ = error {
                                let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                        message: error,
                                                                        preferredStyle: .alert)
                                
                                let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                                
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                                return
                            }
                            
                            if let data = data {
                                guard data.success else {
                                    let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                            message: "\(data.msg_error)",
                                        preferredStyle: .alert)
                                    
                                    let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                                    
                                    alertController.addAction(action)
                                    self.present(alertController, animated: true, completion: nil)
                                    return
                                }
                                
                                if estadoSeguimiento == "1" {
                                    titleAction = "Tu envio se marco para seguimiento exitosamente."
                                    self.responseRastrearEnvio!.data[0].eTracking.tipo_seguimiento = "1"
                                } else {
                                    titleAction = "Tu envío se quitó de seguimiento exitosamente."
                                    self.responseRastrearEnvio!.data[0].eTracking.tipo_seguimiento = "0"
                                }
                                
                                let alertController = UIAlertController(title: titleAction,
                                                                        message: nil,
                                                                        preferredStyle: .alert)
                                
                                let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                                
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                }
            } else {
                Helper.showLoginView(viewController: self)
            }
        })
        
        action.setValue(UIImage(named: "ic_bell_25pt"), forKey: "image")
        
        return action
    }
    
    func actionConfigurarNotificacionesBuild() -> UIAlertAction? {
        guard let idCHK = Int(responseRastrearEnvio!.data[0].eTracking.chk_id),
            (idCHK != Constant.CHKControl.ENTREGADO && idCHK != Constant.CHKControl.DEVOLUCION) else {
                return nil
        }
        
        let action = UIAlertAction(title: "Configurar notificaciones", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if UserSession.isUserLogged() {
                let sb = UIStoryboard(name: "ConfigurarNotificacionesEnvio", bundle: nil)
                let vc = sb.instantiateInitialViewController()! as! UINavigationController
                let subVC = vc.viewControllers[0] as! ConfigurarNotificacionesEnvioTableViewController
                subVC.guiNumero = self.responseRastrearEnvio!.data[0].eTracking.guia
                subVC.lineaNegocio = self.responseRastrearEnvio!.data[0].eTracking.linea_negocio
                self.present(vc, animated: true, completion: nil)
            } else {
                Helper.showLoginView(viewController: self)
            }
        })
        
        action.setValue(UIImage(named: "ic_bell_25pt"), forKey: "image")
        
        return action
    }
    
    func setupReprogramarVisitaAction() -> UIAlertAction? {        
        let action = UIAlertAction(title: "Reprogramar visita", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.showOpcionesDeEntregaActionSheet()
        })
        
        action.setValue(UIImage(named: "ic_calendar_linear_25pt"), forKey: "image")
        
        return action
    }
    
    func showOpcionesDeEntregaActionSheet() {
        let alertController = UIAlertController(title: "Opciones de entrega", message: nil, preferredStyle: .actionSheet)
        
        let agendarVisitaAction = UIAlertAction(title: "Agendar visita", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if let servicioReprogramacion = Int(self.responseRastrearEnvio!.data[0].eTracking.reprogramacion),
               servicioReprogramacion == 1 {
                if UserSession.isUserLogged() {
                    let sb = UIStoryboard(name: "AgendarVisita", bundle: nil)
                    let vc = sb.instantiateInitialViewController() as! UINavigationController
                    let subVC = vc.viewControllers[0] as! AgendarVisitaViewController
                    subVC.guiaNumero = self.responseRastrearEnvio!.data[0].eTracking.guia
                    subVC.lineaNegocio = self.responseRastrearEnvio!.data[0].eTracking.linea_negocio
                    subVC.isEnableTipoServicioOverNight = Int(self.responseRastrearEnvio!.data[0].eTracking.overnight) == 1
                    subVC.isEnableTipoServicioWeekEnd = Int(self.responseRastrearEnvio!.data[0].eTracking.weekend) == 1
                    self.present(vc, animated: true, completion: nil)
                } else {
                    Helper.showLoginView(viewController: self)
                }
            } else {
                self.showDefaultAlert(title: "Agendar Visita",
                                      message: "Lo sentimos el servicio de agendar visita no esta disponible en este momento.")
            }
        })
        
        let retirarEnTiendaAction = UIAlertAction(title: "Retirar en tienda", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if let servicioRetiroTienda = Int(self.responseRastrearEnvio!.data[0].eTracking.retiro_tienda),
               servicioRetiroTienda == 1 {
                if UserSession.isUserLogged() {
                    let sb = UIStoryboard(name: "RetirarEnTienda", bundle: nil)
                    let vc = sb.instantiateInitialViewController() as! UINavigationController
                    let subVC = vc.viewControllers[0] as! RetirarEnTiendaViewController
                    subVC.guiaNumero = self.responseRastrearEnvio!.data[0].eTracking.guia
                    subVC.lineaNegocio = self.responseRastrearEnvio!.data[0].eTracking.linea_negocio
                    self.present(vc, animated: true, completion: nil)
                } else {
                    Helper.showLoginView(viewController: self)
                }
            } else {
                self.showDefaultAlert(title: "Retirar en Tienda",
                                      message: "Lo sentimos el servicio de retirar en tienda no esta disponible en este momento.")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        agendarVisitaAction.setValue(UIImage(named: "ic_calendar_linear_25pt"), forKey: "image")
        retirarEnTiendaAction.setValue(UIImage(named: "ic_store_25pt"), forKey: "image")
        
        alertController.addAction(agendarVisitaAction)
        alertController.addAction(retirarEnTiendaAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func registerSearchTrackingRecord(guia: String) {
        if let record = UserDefaultsManager.shared.searchTrackingRecord {
            if !record.contains(guia) {
                var r = record
                if record.count == 10 {
                    r.remove(at: 0)
                    r.append(guia)
                } else {
                    r.append(guia)
                }
                UserDefaultsManager.shared.searchTrackingRecord = r
            }
        } else {
            UserDefaultsManager.shared.searchTrackingRecord = [guia]
        }
    }
    
    @objc func cancelButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func boxDetalleEstadoGuiaTap(_ sender: UITapGestureRecognizer) {
        let eTracking = responseRastrearEnvio!.data[0].eTracking
        guard let idCHK = Int(eTracking.chk_id) else {
                return
        }
        
        if idCHK == Constant.CHKControl.ENTREGADO
            || idCHK == Constant.CHKControl.NO_ENTREGADO
            || idCHK == Constant.CHKControl.DEVOLUCION {
            performSegue(withIdentifier: "segueFromRastrearEnvioToDetalleVisitaVC", sender: nil)
        } else if idCHK == Constant.CHKControl.SALIO_A_RUTA {
            performSegue(withIdentifier: "segueFromRastrearEnvioToMapaEnvio", sender: nil)
        } else {
            performSegue(withIdentifier: "segueToHistorialTransitoVC", sender: nil)
        }
    }
    
    @objc func boxFotosVisitaEstadoGuiaTap(_ sender: UITapGestureRecognizer) {
        let eTracking = responseRastrearEnvio!.data[0].eTracking
        let movimientos = responseRastrearEnvio!.data[0].historialTransporte
        for movimiento in movimientos {
            if movimiento.id_visita == eTracking.id_visita {
                if movimiento.fotosVisita.count > 0 {
                    let vc = ImagePreviewVC()
                    vc.fotos = movimiento.fotosVisita
                    vc.passedContentOffset = IndexPath(row: 0, section: 0)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc func stackViewContentRemitenteDidTap(_ sender: UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "Tooltip", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! TooltipVC
        vc.text = responseRastrearEnvio!.data[0].eTracking.remite
        
        let fontAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .body)]
        let text = responseRastrearEnvio!.data[0].eTracking.remite
        let size = text.size(withAttributes: fontAttributes)
        
        vc.modalPresentationStyle = .popover
        
        vc.preferredContentSize = CGSize(width: size.width + 20, height: size.height + 20)
        
        let popover = vc.popoverPresentationController
        popover?.permittedArrowDirections = .down
        popover?.delegate = self
        //ppc?.barButtonItem = stackViewContentRemitente
        popover?.sourceView = sender.view
        popover?.backgroundColor = UIColor.white
        popover?.sourceRect = CGRect(x: sender.view!.bounds.midX, y: sender.view!.bounds.midY - 10, width: 0, height: 0)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    struct PalleteColorUrbano {
        static let rojo         = UIColor(red: CGFloat(227/255.0), green: CGFloat(26/255.0), blue: CGFloat(35/255.0), alpha: CGFloat(1.0))
        static let negro        = UIColor(red: CGFloat(38/255.0), green: CGFloat(35/255.0), blue: CGFloat(36/255.0), alpha: CGFloat(1.0))
        static let gris         = UIColor(red: CGFloat(111/255.0), green: CGFloat(112/255.0), blue: CGFloat(115/255.0), alpha: CGFloat(1.0))
        static let background   = UIColor(red: CGFloat(249/255.0), green: CGFloat(249/255.0), blue: CGFloat(249/255.0), alpha: CGFloat(1.0))
    }
    
    func getEtrackingURL() -> String {
        if NetworkManager.shared().environment == API.Environment.Production.rawValue {
            switch UserDefaultsManager.shared.country! {
            case API.Country.Chile:
                return "https://portal.urbanoexpress.cl/rastrear-shipper/";
            case API.Country.Ecuador:
                return "https://portal.urbano.com.ec/rastrear-shipper/";
            case API.Country.Peru:
                return "https://portal.urbano.com.pe/rastrear-shipper/";
            }
        } else {
            return "https://uhd.urbanoexpress.com.pe/rastrear-shipper/";
        }
    }
    
    func showDefaultAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension RastrearEnvioViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}

extension RastrearEnvioViewController: MapaEnvioVCDelegate {
    
    func updateNewGPSCourier(latitude: String, longitude: String, idCHK: String, entregasPendientes: String, horarioEntrega: String) {
        responseRastrearEnvio!.data[0].eTracking.gps_px = latitude
        responseRastrearEnvio!.data[0].eTracking.gps_py = longitude
        responseRastrearEnvio!.data[0].eTracking.chk_id = idCHK
        responseRastrearEnvio!.data[0].eTracking.ge_faltante = entregasPendientes
        responseRastrearEnvio!.data[0].eTracking.horario_ge = horarioEntrega
    }
    
    func updateDetalleRastreoEnvio(data: FetchEnvioResponse) {
        self.processDataRastrearEnvio(data: data)
    }
    
}
