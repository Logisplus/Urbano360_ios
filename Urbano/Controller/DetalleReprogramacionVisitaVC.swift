//
//  DetalleReprogramacionVisitaVC.swift
//  Urbano
//
//  Created by Mick VE on 30/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DetalleReprogramacionVisitaVC: UITableViewController {
    
    var guiaNumero: String?
    var guiaElectronica: String?
    var lineaNegocio: String?
    
    var detalleReprogramacion: FetchDetalleReprogramacionVisitaResponse.DetalleReprogramacion?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        getDetalleReprogramacionVisita()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "DetalleReprogramacionVisitaTableViewCell", bundle: nil), forCellReuseIdentifier: "detalleCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detalleReprogramacion == nil ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detalleCell", for: indexPath) as! DetalleReprogramacionVisitaTableViewCell

        cell.setupDetalle(guiaElectronica: guiaElectronica!, detalleReprogramacion: detalleReprogramacion!)

        return cell
    }
    
    func getDetalleReprogramacionVisita() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = FetchDetalleReprogramacionVisitaRequest(guiNumero: self.guiaNumero!,
                                                             lineaNegocio: self.lineaNegocio!,
                                                             idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.getDetalleReprogramacionVisita(params: params) { (data, error) in
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
                                    
                                    if data.data.count == 1 {
                                        self.processDataDetalleReprogramacion(detalleReprogramacion: data.data[0])
                                    } else {
                                        let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                                message: "No se encontró el detalle de la reprogramación de visita.",
                                            preferredStyle: .alert)
                                        
                                        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        
                                        alertController.addAction(action)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func processDataDetalleReprogramacion(detalleReprogramacion: FetchDetalleReprogramacionVisitaResponse.DetalleReprogramacion) {
        self.detalleReprogramacion = detalleReprogramacion
        self.tableView.reloadData()
    }
    
}
