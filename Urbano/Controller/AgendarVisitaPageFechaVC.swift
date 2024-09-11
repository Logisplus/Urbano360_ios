//
//  AgendarVisitaPageFechaVC.swift
//  Urbano
//
//  Created by Mick VE on 27/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import AudioToolbox

class AgendarVisitaPageFechaVC: UITableViewController {
    
    var guiaNumero: String?
    var lineaNegocio: String?
    var tipoDireccion = -1
    var dataDireccion: [String: String] = [:]
    var dataNuevaDireccion: [String: String] = [:]
    var dataNotificacion: FetchDataReprogramacionResponse.Data.ServicioNotificacion?
    
    var isEnableTipoServicioOverNight = false
    var isEnableTipoServicioWeekEnd = false
    
    var autorizarTercero = false
    var selectedIndexTipoServicio = 0
    var selectedIndexFecha = -1
    var selectedIndexHorario = -1
    
    let fechaPickerView = UIPickerView()
    let horarioPickerView = UIPickerView()
    
    var fechas: [FetchFechasAgendarVisitaResponse.Fecha] = []
    var horarios: [FetchHorariosAgendarVisitaResponse.Horario] = []
    
    var nomAutorizado = ""
    var dniAutorizado = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        navigationItem.backBarButtonItem = backItem
        
        self.fechaPickerView.delegate = self
        self.fechaPickerView.dataSource = self
        self.fechaPickerView.tag = 1
        
        self.horarioPickerView.delegate = self
        self.horarioPickerView.dataSource = self
        self.horarioPickerView.tag = 2
        
        let seguienteButtonBarItem = UIBarButtonItem(title: "Siguiente", style: .plain, target: self, action: #selector(self.siguienteButtonDidTap))
        self.navigationItem.rightBarButtonItem  = seguienteButtonBarItem
        
        self.navigationItem.leftBarButtonItem?.title = "Hola"
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Hola 1"
        self.navigationController?.navigationBar.backItem?.title = "Anything Else"
        
        tableView.register(UINib(nibName: "SegmentedControlTableViewCell", bundle: nil), forCellReuseIdentifier: "segmentedControlCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "switchCell")
        tableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "inputCell")
        
        fetchFechas()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFromFechaToNotificacion" {
            let vc = segue.destination as! AgendarVisitaPageNotificacionVC
            vc.guiaNumero = self.guiaNumero!
            vc.lineaNegocio = self.lineaNegocio!
            vc.tipoDireccion = self.tipoDireccion
            vc.dataDireccion = self.dataDireccion
            vc.dataNuevaDireccion = self.dataNuevaDireccion
            vc.dataFechaVisita = ["fecha": fechas[selectedIndexFecha].fecha,
                                  "idHorario": horarios[selectedIndexHorario].id_arco,
                                  "nomAutorizado": autorizarTercero ? nomAutorizado : "",
                                  "dniAutorizado": autorizarTercero ? dniAutorizado : ""]
            vc.dataNotificacion = self.dataNotificacion
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if autorizarTercero {
            return section == 3 ? 3 : 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "segmentedControlCell", for: indexPath) as! SegmentedControlTableViewCell
            cell.segmentedControl.removeAllSegments()
            cell.segmentedControl.insertSegment(withTitle: "En el día", at: 0, animated: false)
            cell.segmentedControl.insertSegment(withTitle: "Por la noche", at: 1, animated: false)
            cell.segmentedControl.insertSegment(withTitle: "Fin de semana", at: 2, animated: false)
            cell.segmentedControl.selectedSegmentIndex = selectedIndexTipoServicio
            cell.segmentedControl.setEnabled(isEnableTipoServicioOverNight, forSegmentAt: 1)
            cell.segmentedControl.setEnabled(isEnableTipoServicioWeekEnd, forSegmentAt: 2)
            cell.segmentedControl.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
            cell.inputTextField.placeholder = "Seleccionar el día"
            cell.inputTextField.tintColor = UIColor.clear
            cell.inputTextField.delegate = self
            cell.inputTextField.inputView = fechaPickerView
            
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(fechaDidSelect))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            toolbar.setItems([spaceButton,doneButton], animated: false)
            
            cell.inputTextField.inputAccessoryView = toolbar
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
            cell.inputTextField.placeholder = "Seleccionar un horario"
            cell.inputTextField.tintColor = UIColor.clear
            cell.inputTextField.delegate = self
            cell.inputTextField.inputView = horarioPickerView
            
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(horarioDidSelect))
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            toolbar.setItems([spaceButton,doneButton], animated: false)
            
            cell.inputTextField.inputAccessoryView = toolbar
            return cell
        case 3:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as! SwitchTableViewCell
                cell.titleLabel.text = "Autorizar a un tercero"
                cell.mSwitch.isOn = autorizarTercero
                cell.mSwitch.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
                cell.inputTextField.clearButtonMode = .whileEditing
                cell.inputTextField.delegate = self
                
                if indexPath.row == 1 {
                    cell.inputTextField.placeholder = "Nombres y apellidos"
                    cell.inputTextField.keyboardType = .default
                    cell.inputTextField.returnKeyType = .default
                } else {
                    cell.inputTextField.placeholder = "Documento de identificación"
                    cell.inputTextField.keyboardType = .numbersAndPunctuation
                    cell.inputTextField.returnKeyType = .default
                }
                
                return cell
            }
            
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Tipo de servicio"
        case 1:
            return "Fecha"
        case 2:
            return "Horario"
        case 3:
            return "Autorizar"
        default:
            return "No definido"
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Selecciona una fecha en que podrás recibir tu envío"
        case 2:
            return "Selecciona un horario que mas se acomode a tu tiempo"
        case 3:
            return "Activa esta opción para autorizar que un tercero reciba tu envío."
        default:
            return ""
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @objc func segmentedControlDidChange(_ sender: Any) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SegmentedControlTableViewCell
        selectedIndexTipoServicio = cell.segmentedControl.selectedSegmentIndex
        fetchFechas()
    }
    
    @objc func switchDidChange(_ sender: Any) {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! SwitchTableViewCell
        autorizarTercero = cell.mSwitch.isOn
        tableView.reloadData()
    }
    
    @objc func fechaDidSelect() {
        view.endEditing(true)
        
        selectedIndexFecha = fechaPickerView.selectedRow(inComponent: 0)
        
        var cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
        cell.inputTextField.text = formatFecha(fecha: fechas[selectedIndexFecha].fecha)
        
        selectedIndexHorario = -1
        
        cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! InputTableViewCell
        cell.inputTextField.text = ""
        
        fetchHorarios()
    }
    
    @objc func horarioDidSelect() {
        view.endEditing(true)
        
        if horarios.count != 0 {
            selectedIndexHorario = horarioPickerView.selectedRow(inComponent: 0)
            
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! InputTableViewCell
            cell.inputTextField.text = formatHorario(horaDesde: horarios[selectedIndexHorario].desde,
                                                     horaHasta: horarios[selectedIndexHorario].hasta)
        }
    }
    
    @objc func siguienteButtonDidTap() {
        if validateDatos() {
            performSegue(withIdentifier: "segueFromFechaToNotificacion", sender: nil)
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let alert = UIAlertController(title: "Datos incorrectos",
                                          message: "Ingresa correctamente los datos.",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func fetchFechas() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        var idTipoServicio = ""
        
        if selectedIndexTipoServicio == 0 {
            idTipoServicio = "19"
        } else if selectedIndexTipoServicio == 1 {
            idTipoServicio = "20"
        } else if selectedIndexTipoServicio == 2 {
            idTipoServicio = "21"
        }
        
        let idLocalidad = tipoDireccion == 0 ? dataDireccion["idCiudad"] : dataNuevaDireccion["idCiudad"]
        
        let params = FetchFechasAgendarVisitaRequest(guiNumero: self.guiaNumero!,
                                                     motID: "103",
                                                     idAge: "0",
                                                     idLocalidad: idLocalidad!,
                                                     idTipoServicio: idTipoServicio,
                                                     lineaNegocio: self.lineaNegocio!,
                                                     idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.fetchFechasAgendarVisita(params: params) { (data, error) in
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
                                    
                                    self.fechas = data.data
                                    self.fechaPickerView.reloadAllComponents()
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func fetchHorarios() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let idLocalidad = tipoDireccion == 0 ? dataDireccion["idCiudad"] : dataNuevaDireccion["idCiudad"]
        
        let params = FetchHorariosAgendarVisitaRequest(idLocalidad: idLocalidad!,
                                                       fechaVisita: fechas[selectedIndexFecha].fecha,
                                                       lineaNegocio: self.lineaNegocio!,
                                                       idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.fetchHorariosAgendarVisita(params: params) { (data, error) in
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
                                    
                                    self.horarios = data.data
                                    self.horarioPickerView.reloadAllComponents()
                                }
                            })
                        }
                    }
                }
            }
        }
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
    
    func formatHorario(horaDesde: String, horaHasta: String) -> String {
        var dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        
        guard let hd = dateFormatter.date(from: horaDesde) else {
            return "\(horaDesde) a \(horaHasta)"
        }
        
        guard let hh = dateFormatter.date(from: horaHasta) else {
            return "\(horaDesde) a \(horaHasta)"
        }
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        return "\(dateFormatter.string(from: hd)) a \(dateFormatter.string(from: hh))"
    }
    
    func validateDatos() -> Bool {
        if selectedIndexFecha == -1 {
            return false
        }
        
        if selectedIndexHorario == -1 {
            return false
        }
        
        if autorizarTercero {
            // validar nombres y apellidos
            var cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 3)) as! InputTableViewCell
            if let value = cell.inputTextField.text, value.count == 0 {
                return false
            }
            
            nomAutorizado = cell.inputTextField.text!
            
            // validar documento de identificacion
            cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 3)) as! InputTableViewCell
            if let value = cell.inputTextField.text, value.count == 0 {
                return false
            }
            
            dniAutorizado = cell.inputTextField.text!
        }
        
        return true
    }
}

extension AgendarVisitaPageFechaVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}

extension AgendarVisitaPageFechaVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? fechas.count : horarios.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 1
            ? formatFecha(fecha: fechas[row].fecha)
            : formatHorario(horaDesde: horarios[row].desde, horaHasta: horarios[row].hasta)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            selectedIndexFecha = row
            
            var cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
            cell.inputTextField.text = formatFecha(fecha: fechas[row].fecha)
            
            selectedIndexHorario = -1
            
            cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! InputTableViewCell
            cell.inputTextField.text = ""
        } else {
            if horarios.count != 0 {
                selectedIndexHorario = row
                
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! InputTableViewCell
                cell.inputTextField.text = formatHorario(horaDesde: horarios[row].desde,
                                                         horaHasta: horarios[row].hasta)
            }
        }
    }
    
}
