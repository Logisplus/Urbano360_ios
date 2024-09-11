//
//  DetalleRetirarEnTiendaVC.swift
//  Urbano
//
//  Created by Mick VE on 30/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DetalleRetirarEnTiendaVC: UITableViewController {
    
    var guiaNumero: String?
    var lineaNegocio: String?
    
    var agencia: ReprogramarVisita.FetchAgenciasReprogramacion.Response.Agencias?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Tienda: \(agencia!.prov_descri.capitalized)"
        
        let seguienteButtonBarItem = UIBarButtonItem(title: "Recoger", style: .plain, target: self, action: #selector(self.enviarButtonDidTap))
        self.navigationItem.rightBarButtonItem  = seguienteButtonBarItem

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "DetalleRetirarEnTiendaTableViewCell", bundle: nil), forCellReuseIdentifier: "detalleCell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "detalleCell", for: indexPath) as! DetalleRetirarEnTiendaTableViewCell
        cell.setupDetalle(direccion: agencia!.dir_calle.capitalized,
                          horario: agencia!.horario,
                          telefono: agencia!.telefonos,
                          contactarCon: agencia!.contactos.capitalized,
                          fechaAproximada: formatFecha(fecha: agencia!.fecha))

        return cell
    }
    
    @objc func enviarButtonDidTap() {
        let alert = UIAlertController(title: "Retirar envío en tienda",
                                      message: "¿Estás seguro de recoger tu envío en la tienda “\(agencia!.prov_descri.capitalized)”",
                                      preferredStyle: .alert)
        let enviarAction = UIAlertAction(title: "Recoger", style: .default) { (action:UIAlertAction) in
            self.uploadAgenderVisita()
        }
        
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel) { (action:UIAlertAction) in }
        
        alert.addAction(cancelarAction)
        alert.addAction(enviarAction)
        present(alert, animated: true, completion: nil)
    }
    
    func formatFecha(fecha: String) -> String {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatter.date(from: fecha) {
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "EEEE"
            let dayName = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "MMMM"
            let monthName = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: date)
            return "\(dayName.capitalized), \(day) de \(monthName.capitalized) del \(year)"
        } else {
            return "Fecha no valida."
        }
    }
    
    func uploadAgenderVisita() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = UploadAgendarVisitaRequest(guiNumero: self.guiaNumero!,
                                                idMotivo: "105",
                                                idDireccion: agencia!.dir_id,
                                                idCiudad: agencia!.ciu_id,
                                                direccionEntrega: "",
                                                transversal: "",
                                                nroPuerta: "",
                                                nroInterior: "",
                                                referencia: "",
                                                latitude: "",
                                                longitude: "",
                                                fechaVisita: agencia!.fecha,
                                                idHora: "",
                                                nombreAutorizado: "",
                                                dniAutorizado: "",
                                                estadoNotifyLD: "",
                                                estadoNotifyDL: "",
                                                estadoNotifyCA: "",
                                                telefono: "",
                                                correo: "",
                                                lineaNegocio: self.lineaNegocio!,
                                                idUsuario: UserSession.getUserSessionID(),
                                                idUser: "1")
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.uploadAgendarVisita(params: params) { (data, error) in
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
                                    
                                    let alertController = UIAlertController(title: "Tu retiro en tienda fue registrada exitosamente.",
                                                                            message: "",
                                                                            preferredStyle: .alert)
                                    
                                    let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                    alertController.addAction(action)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }

}
