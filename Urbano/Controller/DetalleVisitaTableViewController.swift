//
//  DetalleVisitaTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 16/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DetalleVisitaTableViewController: UITableViewController, DetalleVisitaTableViewCellDelegate {
    
    var eTracking: FetchEnvioResponse.Data.ETracking?
    var movimientoGuia: FetchEnvioResponse.Data.HistorialTransporte?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        navigationItem.backBarButtonItem = backItem
        
        setupTitle()
        
        setupBarButton()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "DetalleVisitaTableViewCell", bundle: nil), forCellReuseIdentifier: "detalleVisitaCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detalleVisitaCell", for: indexPath) as! DetalleVisitaTableViewCell
        cell.delegate = self
        cell.viewSetup(eTracking: eTracking!, movimientoGuia: movimientoGuia!)

        return cell
    }
    
    func setupTitle() {
        if let idCHK = Int(movimientoGuia!.chk_id) {
            if idCHK == Constant.CHKControl.ENTREGADO {
                self.navigationItem.title = "Detalle de la entrega"
            } else if (idCHK == Constant.CHKControl.NO_ENTREGADO
                || idCHK == Constant.CHKControl.CLIENTE_VISITADO) {
                self.navigationItem.title = "Detalle de la visita"
            }
        }
    }
    
    func setupBarButton() {
        if let idCHK = Int(movimientoGuia!.chk_id) {
            if idCHK == Constant.CHKControl.ENTREGADO {
                let calificarButton = UIBarButtonItem(image: UIImage(named: "ic_star_25pt"), style: .plain, target: self, action: #selector(calificarButtonDidTap))
                navigationItem.rightBarButtonItem = calificarButton
            } else if (idCHK == Constant.CHKControl.NO_ENTREGADO
                || idCHK == Constant.CHKControl.CLIENTE_VISITADO) {
                if let servicioReprogramacion = Int(eTracking!.reprogramacion),
                    servicioReprogramacion == 1 {
                    let reprogramarButton = UIBarButtonItem(image: UIImage(named: "ic_calendar_bar_button_25pt"), style: .plain, target: self, action: #selector(reprogramarButtonDidTap))
                        navigationItem.rightBarButtonItem = reprogramarButton
                }
            }
        }
    }
    
    @objc func calificarButtonDidTap() {
        if UserSession.isUserLogged() {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalificarServicioStoryboard") as! UINavigationController
            let subVC = vc.viewControllers[0] as! CalificarServicioVC
            subVC.guiaNumero = self.eTracking!.guia
            subVC.lineaNegocio = self.eTracking!.linea_negocio
            present(vc, animated: true, completion: nil)
        } else {
            Helper.showLoginView(viewController: self)
        }
    }
    
    @objc func reprogramarButtonDidTap() {
        if UserSession.isUserLogged() {
            let alertController = UIAlertController(title: "Opciones de entrega", message: nil, preferredStyle: .actionSheet)
            
            let agendarVisitaAction = UIAlertAction(title: "Agendar visita", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                let sb = UIStoryboard(name: "AgendarVisita", bundle: nil)
                let vc = sb.instantiateInitialViewController() as! UINavigationController
                let subVC = vc.viewControllers[0] as! AgendarVisitaViewController
                subVC.guiaNumero = self.eTracking!.guia
                subVC.lineaNegocio = self.eTracking!.linea_negocio
                subVC.isEnableTipoServicioOverNight = Int(self.eTracking!.overnight) == 1
                subVC.isEnableTipoServicioWeekEnd = Int(self.eTracking!.weekend) == 1
                self.present(vc, animated: true, completion: nil)
            })
            
            let retirarEnTiendaAction = UIAlertAction(title: "Retirar en tienda", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                let sb = UIStoryboard(name: "RetirarEnTienda", bundle: nil)
                let vc = sb.instantiateInitialViewController() as! UINavigationController
                let subVC = vc.viewControllers[0] as! RetirarEnTiendaViewController
                subVC.guiaNumero = self.eTracking!.guia
                subVC.lineaNegocio = self.eTracking!.linea_negocio
                self.present(vc, animated: true, completion: nil)
            })
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
            
            agendarVisitaAction.setValue(UIImage(named: "ic_calendar_linear_25pt"), forKey: "image")
            retirarEnTiendaAction.setValue(UIImage(named: "ic_store_25pt"), forKey: "image")
            
            alertController.addAction(agendarVisitaAction)
            alertController.addAction(retirarEnTiendaAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            Helper.showLoginView(viewController: self)
        }
    }
    
    func didSelectItemAt(indexPath: IndexPath) {
        let vc = ImagePreviewVC()
        vc.fotos = movimientoGuia!.fotosVisita
        vc.passedContentOffset = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
