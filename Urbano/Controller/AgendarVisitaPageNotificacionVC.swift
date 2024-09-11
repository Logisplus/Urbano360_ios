//
//  AgendarVisitaPageNotificacionVC.swift
//  Urbano
//
//  Created by Mick VE on 29/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import AudioToolbox

class AgendarVisitaPageNotificacionVC: UITableViewController {
    
    var guiaNumero: String?
    var lineaNegocio: String?
    var tipoDireccion = -1
    var dataDireccion: [String: String] = [:]
    var dataNuevaDireccion: [String: String] = [:]
    var dataFechaVisita: [String: String] = [:]
    var dataNotificacion: FetchDataReprogramacionResponse.Data.ServicioNotificacion?
    var notificaciones: [[String: String]] = []
    
    var correo = ""
    var telefono = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificaciones = [["notificacion": "Cuando mi envío este en transito.",
                           "estado": dataNotificacion!.notify_ld],
                          ["notificacion": "Cuando mi envío esta entregado.",
                           "estado": dataNotificacion!.notify_dl],
                          ["notificacion": "Cuando mi envío no se pudo entregar.",
                           "estado": dataNotificacion!.notify_ca]]
        
        let enviarButtonBarItem = UIBarButtonItem(title: "Enviar", style: .plain, target: self, action: #selector(self.enviarButtonDidTap))
        self.navigationItem.rightBarButtonItem  = enviarButtonBarItem
        
        tableView.allowsMultipleSelection = true
        tableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "inputCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificacionCell", for: indexPath)
            cell.textLabel?.text = notificaciones[indexPath.row]["notificacion"]!
            cell.textLabel?.numberOfLines = 0
            cell.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
            
            if let estado = Int(notificaciones[indexPath.row]["estado"]!), estado == 1 {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.accessoryType = .checkmark
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
            cell.inputTextField.clearButtonMode = .whileEditing
            cell.inputTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            cell.inputTextField.delegate = self
            //cell.isSelected = true
            
            if indexPath.row == 0 {
                cell.inputTextField.tag = 1
                cell.inputTextField.placeholder = "Correo"
                cell.inputTextField.textContentType = UITextContentType.emailAddress
                cell.inputTextField.keyboardType = .emailAddress
                cell.inputTextField.returnKeyType = .next
                cell.inputTextField.text = dataNotificacion!.correo
            } else {
                cell.inputTextField.tag = 2
                cell.inputTextField.placeholder = "Teléfono celular"
                cell.inputTextField.textContentType = UITextContentType.telephoneNumber
                cell.inputTextField.keyboardType = .phonePad
                cell.inputTextField.returnKeyType = .default
                cell.inputTextField.text = dataNotificacion!.telefono
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Notificaciones" : ""
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Selecciona uno o más notificaciones para informarte los estados de tu envío."
        } else {
            return "Configura la vía por donde quieres recibir tus notificaciones."
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            cell!.accessoryType = .checkmark
            notificaciones[indexPath.row]["estado"] = "1"
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! InputTableViewCell
            cell.inputTextField.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRow(at: indexPath)
            cell!.accessoryType = .none
            notificaciones[indexPath.row]["estado"] = "0"
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @objc func enviarButtonDidTap() {
        if isNotificationsActive() {
            let cellEmail = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
            let cellPhone = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputTableViewCell
            correo = cellEmail.inputTextField.text!.trimmingCharacters(in: .whitespaces)
            telefono = cellPhone.inputTextField.text!.trimmingCharacters(in: .whitespaces)
            
            if correo.count != 0 || telefono.count != 0 {
                if correo.count != 0 {
                    if !Helper.isValidEmail(email: correo) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        
                        cellEmail.inputTextField.textColor = UIColor(red: CGFloat(255/255.0), green: CGFloat(59/255.0), blue: CGFloat(48/255.0), alpha: CGFloat(1.0))
                        
                        let alert = UIAlertController(title: "Datos incorrectos", message: "El correo que ingresaste no es valido.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                            cellEmail.becomeFirstResponder()
                        }
                        
                        alert.addAction(action)
                        present(alert, animated: true, completion: nil)
                        
                        return
                    }
                }
                
                view.endEditing(true)
                uploadAgenderVisita()
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                let alert = UIAlertController(title: "Datos incorrectos",
                                              message: "Ingresa correctamente los datos.",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } else {
            view.endEditing(true)
            uploadAgenderVisita()
        }
    }
    
    func isNotificationsActive() -> Bool {
        for notificacion in notificaciones {
            if let estado = Int(notificacion["estado"]!), estado == 1 {
                return true
            }
        }
        return false
    }
    
    func uploadAgenderVisita() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        var params: UploadAgendarVisitaRequest
        
        if tipoDireccion == 0 {
            params = UploadAgendarVisitaRequest(guiNumero: self.guiaNumero!,
                                           idMotivo: "103",
                                           idDireccion: dataDireccion["idDireccion"]!,
                                           idCiudad: dataDireccion["idCiudad"]!,
                                           direccionEntrega: "",
                                           transversal: "",
                                           nroPuerta: "",
                                           nroInterior: "",
                                           referencia: dataDireccion["referencia"]!,
                                           latitude: dataDireccion["latitude"]!,
                                           longitude: dataDireccion["longitude"]!,
                                           fechaVisita: dataFechaVisita["fecha"]!,
                                           idHora: dataFechaVisita["idHorario"]!,
                                           nombreAutorizado: dataFechaVisita["nomAutorizado"]!,
                                           dniAutorizado: dataFechaVisita["dniAutorizado"]!,
                                           estadoNotifyLD: notificaciones[0]["estado"]!,
                                           estadoNotifyDL: notificaciones[1]["estado"]!,
                                           estadoNotifyCA: notificaciones[2]["estado"]!,
                                           telefono: telefono,
                                           correo: correo,
                                           lineaNegocio: self.lineaNegocio!,
                                           idUsuario: UserSession.getUserSessionID(),
                                           idUser: "1")
        } else {
            params = UploadAgendarVisitaRequest(guiNumero: self.guiaNumero!,
                                           idMotivo: "103",
                                           idDireccion: "0",
                                           idCiudad: dataNuevaDireccion["idCiudad"]!,
                                           direccionEntrega: dataNuevaDireccion["direccion"]!,
                                           transversal: "",
                                           nroPuerta: dataNuevaDireccion["nroPuerta"]!,
                                           nroInterior: dataNuevaDireccion["nroInterior"]!,
                                           referencia: dataNuevaDireccion["referencia"]!,
                                           latitude: dataNuevaDireccion["latitude"]!,
                                           longitude: dataNuevaDireccion["longitude"]!,
                                           fechaVisita: dataFechaVisita["fecha"]!,
                                           idHora: dataFechaVisita["idHorario"]!,
                                           nombreAutorizado: dataFechaVisita["nomAutorizado"]!,
                                           dniAutorizado: dataFechaVisita["dniAutorizado"]!,
                                           estadoNotifyLD: notificaciones[0]["estado"]!,
                                           estadoNotifyDL: notificaciones[1]["estado"]!,
                                           estadoNotifyCA: notificaciones[2]["estado"]!,
                                           telefono: telefono,
                                           correo: correo,
                                           lineaNegocio: self.lineaNegocio!,
                                           idUsuario: UserSession.getUserSessionID(),
                                           idUser: "1")
        }
        
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
                                    
                                    let alertController = UIAlertController(title: "La reprogramación de visita fue registrada exitosamente.",
                                                                            message: "",
                                                                            preferredStyle: .alert)
                                    
                                    let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                                        //self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                                        //self.navigationController?.popToRootViewController(animated: true)
                                        self.navigationController?.dismiss(animated: true, completion: nil)
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

extension AgendarVisitaPageNotificacionVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        if textField.tag == 1 {
            let cellPhone = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputTableViewCell
            cellPhone.inputTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
}
