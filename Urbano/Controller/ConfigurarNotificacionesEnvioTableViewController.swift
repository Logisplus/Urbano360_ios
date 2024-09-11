//
//  ConfigurarNotificacionesEnvioTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 22/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import AudioToolbox

class ConfigurarNotificacionesEnvioTableViewController: UITableViewController, UITextFieldDelegate {
    
    var isRowCargandoHidden: Bool = false
    
    var guiNumero: String?
    var lineaNegocio: String?
    
    var notificaciones: [FetchServicioNotificacionEnvioResponse.Notificaciones]?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 44
        tableView.allowsMultipleSelection = true
        tableView.register(UINib(nibName: "CargandoTableViewCell", bundle: nil), forCellReuseIdentifier: "cargandoCell")
        tableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "inputCell")
        
        fetchServicioNotificacionEnvioRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStopDidClick(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSaveDidClick(_ sender: Any) {
        //print(tableView.indexPathsForSelectedRows)
        let cellEmail = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
        let cellPhone = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputTableViewCell
        let email = cellEmail.inputTextField.text!.trimmingCharacters(in: .whitespaces)
        let phone = cellPhone.inputTextField.text!.trimmingCharacters(in: .whitespaces)
        if Helper.isValidEmail(email: email) {
            self.view.endEditing(true)
            
            var notificacionesParams = [UploadServicioNotificacionEnvioRequest.Notificaciones]()
            
            for n in notificaciones! {
                notificacionesParams.append(UploadServicioNotificacionEnvioRequest.Notificaciones(id_notify: n.id_notify,
                                                                                                  estado: n.estado))
            }
            
            do {
                let notificacionesData = try JSONEncoder().encode(notificacionesParams)
                let notificacionesFormated = String(data: notificacionesData, encoding: .utf8)!
                let params = UploadServicioNotificacionEnvioRequest(guiNumero: guiNumero!,
                                                                               notificaciones: notificacionesFormated,
                                                                               correo: email,
                                                                               telefono: phone,
                                                                               lineaNegocio: lineaNegocio!,
                                                                               idUsuario: UserSession.getUserSessionID())
                
                saveServicioNotificacionEnvioRequest(params: params)
            } catch let er {
                print("Error al convertir a json las notificaciones")
            }
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            cellEmail.inputTextField.textColor = UIColor(red: CGFloat(255/255.0), green: CGFloat(59/255.0), blue: CGFloat(48/255.0), alpha: CGFloat(1.0))
            let alert = UIAlertController(title: "Datos incorrectos", message: "El correo que ingresaste no es valido.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    /*
     Define UIColor from hex value
     
     @param rgbValue - hex color value
     @param alpha - transparency level
     */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if !isRowCargandoHidden {
            return 1
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if !isRowCargandoHidden {
            return 1
        } else {
            return section == 0 ? notificaciones!.count : 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isRowCargandoHidden {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cargandoCell", for: indexPath) as! CargandoTableViewCell
            cell.activityIndicatorView.startAnimating()
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "notificacionCell", for: indexPath)
                cell.textLabel?.text = notificaciones?[indexPath.row].descri_notify
                cell.textLabel?.numberOfLines = 0
                cell.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
                
                if let estado = Int(notificaciones![indexPath.row].estado), estado == 1 {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    cell.accessoryType = .checkmark
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
                cell.inputTextField.clearButtonMode = .whileEditing
                cell.inputTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                cell.inputTextField.delegate = self
                cell.isSelected = true
                
                if indexPath.row == 0 {
                    cell.inputTextField.tag = 1
                    cell.inputTextField.placeholder = "Correo"
                    cell.inputTextField.textContentType = UITextContentType.emailAddress
                    cell.inputTextField.keyboardType = .emailAddress
                    cell.inputTextField.returnKeyType = .next
                    
                    if let notify = notificaciones?[0], !notify.correo.isEmpty {
                        cell.inputTextField.text = notify.correo
                    }
                } else {
                    cell.inputTextField.tag = 2
                    cell.inputTextField.placeholder = "Teléfono celular"
                    cell.inputTextField.textContentType = UITextContentType.telephoneNumber
                    cell.inputTextField.keyboardType = .phonePad
                    cell.inputTextField.returnKeyType = .done
                    
                    if let notify = notificaciones?[0], !notify.telefono.isEmpty {
                        cell.inputTextField.text = notify.telefono
                    }
                }
                
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isRowCargandoHidden {
            return UITableViewAutomaticDimension
        } else {
            if indexPath.section == 0 {
                return UITableViewAutomaticDimension
            } else {
                return CGFloat(44)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isRowCargandoHidden  {
            if indexPath.section == 0 {
                return indexPath
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isRowCargandoHidden  {
            if indexPath.section == 0 {
                let cell = tableView.cellForRow(at: indexPath)
                cell!.accessoryType = .checkmark
                notificaciones![indexPath.row].estado = "1"
                
                enableButtonSave()
            } else {
                let cell = tableView.cellForRow(at: indexPath) as! InputTableViewCell
                cell.inputTextField.becomeFirstResponder()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isRowCargandoHidden  {
            if indexPath.section == 0 {
                let cell = tableView.cellForRow(at: indexPath)
                cell!.accessoryType = .none
                notificaciones![indexPath.row].estado = "0"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if isRowCargandoHidden  {
            if section == 0 {
                return "Selecciona uno o más notificaciones para informarte los estados de tu envío."
            } else {
                return "Configura la vía por donde quieres recibir tus notificaciones."
            }
        }
        return nil
    }
    
    // MARK: - TextField
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
        enableButtonSave()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 1 {
            let cellPhone = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputTableViewCell
            cellPhone.inputTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 2 {
            guard let value = textField.text else { return true }
            let newLength = value.count + string.count - range.length
            return newLength <= 10
        } else {
            return true
        }
    }
    
    func isNotificationsActive() -> Bool {
        for notificacion in self.notificaciones! {
            if let estado = Int(notificacion.estado), estado == 1 {
                return true
            }
        }
        return false
    }
    
    func enableButtonSave() {
        if isNotificationsActive() {
            let cellEmail = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
            let cellPhone = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! InputTableViewCell
            if !cellEmail.inputTextField.text!.isEmpty || !cellPhone.inputTextField.text!.isEmpty {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func fetchServicioNotificacionEnvioRequest() {
        let params = FetchServicioNotificacionEnvioRequest(guiNumero: guiNumero!,
                                                           lineaNegocio: lineaNegocio!,
                                                           idUsuario: UserSession.getUserSessionID())
        
        API.getServicioNotificacionEnvio(params: params) { (data, error) in
            DispatchQueue.main.async {
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
                    
                    if data.data.count == 0 {
                        let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                message: "Actualmente el envío no tiene notificaciones para configurar.",
                                                                preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.notificaciones = data.data
                        self.isRowCargandoHidden = true
                        self.tableView.reloadData()
                        self.enableButtonSave()
                    }
                }
            }
        }
    }
    
    func saveServicioNotificacionEnvioRequest(params: UploadServicioNotificacionEnvioRequest) {
        let loadingViewController = LoadingViewController(message: "Loading...")
        present(loadingViewController, animated: true, completion: nil)
        
        API.uploadServicioNotificacionEnvio(params: params) { (data, error) in
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
                        
                        let alertController = UIAlertController(title: nil,
                                                                message: "Tu configuración de notificaciones se guardo exitosamente.",
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
