//
//  AgendarVisitaViewController.swift
//  Urbano
//
//  Created by Mick VE on 25/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import AudioToolbox

class AgendarVisitaViewController: UIViewController {

    @IBOutlet weak var boxTipoDireccionView: UIView!
    @IBOutlet weak var tipoDireccionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    /*lazy var nuevaDireccionVC: NuevaDireccionRVTableViewController = {
        var vc = storyboard?.instantiateViewController(withIdentifier: "NuevaDireccionStoryboard") as! NuevaDireccionRVTableViewController
        
        self.addViewControllerAsChildViewController(childViewController: vc)
        
        return vc
    }()
    
    lazy var listaDireccionesVC: ListaDireccionesRVTableViewController = {
        var vc = storyboard?.instantiateViewController(withIdentifier: "ListaDireccionesStoryboard") as! ListaDireccionesRVTableViewController
        
        self.addViewControllerAsChildViewController(childViewController: vc)
        
        return vc
    }()*/
    
    var listaDireccionesView: UIView!
    var nuevaDireccionView: UIView!
    
    var listaDireccionesVC: ListaDireccionesRVTableViewController!
    var nuevaDireccionVC: NuevaDireccionRVTableViewController!
    
    var loadingViewController: LoadingViewController?
    
    var guiaNumero: String?
    var lineaNegocio: String?
    var isEnableTipoServicioOverNight = false
    var isEnableTipoServicioWeekEnd = false
    
    var selectedIndexDireccion = -1
    var dataReprogramacion: FetchDataReprogramacionResponse.Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        fetchDataReprogramacion()
        
        /*listaDireccionesVC.view.isHidden = true
        nuevaDireccionVC.view.isHidden = false*/
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromUbicacionToFecha" {
            let vc = segue.destination as! AgendarVisitaPageFechaVC
            vc.guiaNumero = self.guiaNumero!
            vc.lineaNegocio = self.lineaNegocio!
            vc.tipoDireccion = self.selectedIndexDireccion
            vc.dataNotificacion = self.dataReprogramacion!.servNotify
            
            if selectedIndexDireccion == 0 {
                print("ACTUAL DIRECCION")
                vc.dataDireccion = [
                    "idDireccion": dataReprogramacion!.direcciones[selectedIndexDireccion].dir_id,
                    "idCiudad": dataReprogramacion!.direcciones[selectedIndexDireccion].ciu_id,
                    "referencia": dataReprogramacion!.direcciones[selectedIndexDireccion].referencia,
                    "latitude": dataReprogramacion!.direcciones[selectedIndexDireccion].px,
                    "longitude": dataReprogramacion!.direcciones[selectedIndexDireccion].py,
                ]
            } else {
                print("NUEVA DIRECCION")
                vc.dataNuevaDireccion = nuevaDireccionVC.getDataNuevaDireccion()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tipoDireccionDidChange(_ sender: UISegmentedControl) {
        //updateContainerViews()
        
        self.view.endEditing(true)
        
        selectedIndexDireccion = sender.selectedSegmentIndex
        
        switch sender.selectedSegmentIndex {
        case 0:
            containerView.bringSubview(toFront: listaDireccionesView)
        case 1:
            containerView.bringSubview(toFront: nuevaDireccionView)
        default: break
        }
    }
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func siguienteButtonDidTap(_ sender: Any) {
        if tipoDireccionSegmentedControl.selectedSegmentIndex == 0 {
            if selectedIndexDireccion >= 0 {
                performSegue(withIdentifier: "segueFromUbicacionToFecha", sender: nil)
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                let alert = UIAlertController(title: "Datos incorrectos", message: "Seleccione una dirección.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } else {
            if nuevaDireccionVC.validateDatos() {
                performSegue(withIdentifier: "segueFromUbicacionToFecha", sender: nil)
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                let alert = UIAlertController(title: "Datos incorrectos",
                                              message: "Ingresa correctamente los datos de la nueva dirección.",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setupViews() {
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        navigationItem.backBarButtonItem = backItem
        
        boxTipoDireccionView.backgroundColor = UIColor.white
        
        tipoDireccionSegmentedControl.removeSegment(at: 1, animated: false)
        tipoDireccionSegmentedControl.tintColor = ColorPalette.Urbano.rojo
        
        setupVCSections()
        
        setupContainerView()
    }
    
    func setupVCSections() {
        listaDireccionesVC = storyboard?.instantiateViewController(withIdentifier: "ListaDireccionesStoryboard") as! ListaDireccionesRVTableViewController
        listaDireccionesVC.delegate = self
        
        nuevaDireccionVC = storyboard?.instantiateViewController(withIdentifier: "NuevaDireccionStoryboard") as! NuevaDireccionRVTableViewController
        nuevaDireccionVC.lineaNegocio = self.lineaNegocio!
        
        listaDireccionesView = listaDireccionesVC.view
        nuevaDireccionView = nuevaDireccionVC.view
    }
    
    func setupContainerView() {
        addChildViewController(listaDireccionesVC)
        containerView.addSubview(listaDireccionesView)
        listaDireccionesView.frame = containerView.bounds
        listaDireccionesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listaDireccionesVC.didMove(toParentViewController: self)
        
        addChildViewController(nuevaDireccionVC)
        containerView.addSubview(nuevaDireccionView)
        nuevaDireccionView.frame = containerView.bounds
        nuevaDireccionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nuevaDireccionVC.didMove(toParentViewController: self)
        
        containerView.bringSubview(toFront: listaDireccionesView)
    }
    
    func fetchDataReprogramacion() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = FetchDataReprogramacionRequest(guiNumero: self.guiaNumero!,
                                                    lineaNegocio: self.lineaNegocio!,
                                                    idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.getDataReprogramacion(params: params) { (data, error) in
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
                                
                                if let _ = data {
                                    guard data!.success else {
                                        let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                                message: "\(data!.msg_error)",
                                            preferredStyle: .alert)
                                        
                                        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                                        
                                        alertController.addAction(action)
                                        self.present(alertController, animated: true, completion: nil)
                                        return
                                    }
                                }
                                
                                self.processDataReprogramacion(data: data!.data)
                            })
                        }
                    }
                }
            }
        }
    }
    
    func processDataReprogramacion(data: FetchDataReprogramacionResponse.Data) {
        self.dataReprogramacion = data
        self.selectedIndexDireccion = data.direcciones.count > 0 ? 0 : -1 // seleccionar por defecto el primero
        processDirecciones(direcciones: data.direcciones)
        setupTipoDireccionSegmentedControl(totalDirecciones: data.direcciones.count,
                                           isEnableButtonNuevaDireccion: (Int(data.reglaNuevaDireccion) ?? 0) == 1 ? true : false)
    }
    
    func processDirecciones(direcciones: [FetchDataReprogramacionResponse.Data.Direccion]) {
        var dirs: [ListaDireccionesRVTableViewController.Direccion] = []
        
        for i in 0..<direcciones.count {
            dirs.append(ListaDireccionesRVTableViewController.Direccion(idDireccion: direcciones[i].dir_id,
                                                                        distrito: direcciones[i].distrito.capitalized,
                                                                        direccion: direcciones[i].direccion.capitalized,
                                                                        referencia: parseReferencia(referencia: direcciones[i].referencia),
                                                                        idCiudad: direcciones[i].ciu_id,
                                                                        latitude: direcciones[i].px,
                                                                        longitude: direcciones[i].py,
                                                                        selected: i == 0))
        }
        
        listaDireccionesVC.showDirecciones(direcciones: dirs)
    }
    
    func parseReferencia(referencia: String) -> String {
        var ref: String
        
        if referencia.isEmpty {
            ref = ""
        } else {
            if let _ = Int(referencia) {
                ref = ""
            } else {
                ref = referencia.capitalized
            }
        }
        
        return ref
    }
    
    func setupTipoDireccionSegmentedControl(totalDirecciones: Int, isEnableButtonNuevaDireccion: Bool) {
        if totalDirecciones == 1 {
            tipoDireccionSegmentedControl.setTitle("Dirección", forSegmentAt: 0)
        } else {
            tipoDireccionSegmentedControl.setTitle("Direcciones (\(totalDirecciones))", forSegmentAt: 0)
        }
        
        if isEnableButtonNuevaDireccion {
            tipoDireccionSegmentedControl.insertSegment(withTitle: "Nuevo", at: 1, animated: true)
        }
    }
    
    /*func addViewControllerAsChildViewController(childViewController: UIViewController) {
        addChildViewController(childViewController)
        
        view.addSubview(childViewController.view)
        
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childViewController.didMove(toParentViewController: self)
    }
    
    func updateContainerViews() {
        listaDireccionesVC.view.isHidden = !(tipoDireccionSegmentedControl.selectedSegmentIndex == 0)
        nuevaDireccionVC.view.isHidden = (tipoDireccionSegmentedControl.selectedSegmentIndex == 0)
    }*/

}

extension AgendarVisitaViewController: ListaDireccionesVCDelegate {
    
    func distritoDidSelect(index: Int) {
        selectedIndexDireccion = index
    }
    
    func referenciaDidChange(index: Int, referencia: String) {
        dataReprogramacion!.direcciones[index].referencia = referencia
    }
    
    func coordenadaDidChange(index: Int, latitude: String, longitude: String) {
        dataReprogramacion!.direcciones[index].px = latitude
        dataReprogramacion!.direcciones[index].py = longitude
    }
    
}
