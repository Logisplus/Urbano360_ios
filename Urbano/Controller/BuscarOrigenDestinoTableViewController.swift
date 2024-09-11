//
//  CotizarEnvioTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 10/09/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import AudioToolbox

class BuscarOrigenDestinoTableViewController: UITableViewController, UITextFieldDelegate, ListaDepartamentosVCDelegate {
    
    var isRowCargandoHidden: Bool = false
    
    var departamentos: [FetchDepartamentosResponse.Departamento] = []
    
    var distritos: [FetchDistritosPorDepartamentoResponse.Distrito] = []
    
    var selectedIndexDepartamento = -1
    
    var delegate: CotizarEnvioVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        fetchDepartamentosRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isRowCargandoHidden {
            return distritos.count > 0 ? 3 : 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRowCargandoHidden {
            return section == 2 ? distritos.count : 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isRowCargandoHidden {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cargandoCell", for: indexPath) as! CargandoTableViewCell
            cell.activityIndicatorView.startAnimating()
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                if selectedIndexDepartamento >= 0 {
                    cell.textLabel?.text = departamentos[selectedIndexDepartamento].nombre.capitalized
                    cell.textLabel?.textColor = UIColor.darkText
                } else {
                    switch UserDefaultsManager.shared.country! {
                    case .Chile:
                        cell.textLabel?.text = "Región"
                    case .Ecuador:
                        cell.textLabel?.text = "Provincia"
                    case .Peru:
                        cell.textLabel?.text = "Departamento"
                    }
                }
                return cell
            } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
                cell.inputTextField.clearButtonMode = .whileEditing
                cell.inputTextField.addTarget(self, action: #selector(self.distritoTextFieldDidChange(_:)), for: .editingChanged)
                cell.inputTextField.delegate = self
                cell.isSelected = true
                cell.inputTextField.returnKeyType = .search
                return cell
            } else {
                if Int(distritos[indexPath.row].ciu_id)! > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "distritoCell", for: indexPath)
                    cell.textLabel?.text = distritos[indexPath.row].distrito.capitalized
                    cell.detailTextLabel?.text = "\(distritos[indexPath.row].provincia.capitalized), \(distritos[indexPath.row].departamento.capitalized)"
                    
                    if Int(distritos[indexPath.row].cobertura)! == 1 {
                        cell.imageView?.image = UIImage(named: "ic_map_marker_25pt")
                    } else {
                        cell.imageView?.image = UIImage(named: "ic_map_marker_grey_25pt")
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noExisteDistritoCell", for: indexPath)
                    cell.textLabel?.text = distritos[indexPath.row].distrito.capitalized
                    return cell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleDepartamento = ""
        var titleDistrito = ""

        switch UserDefaultsManager.shared.country! {
        case .Chile:
            titleDepartamento = "Selecciona una región"
            titleDistrito = "Busca una comuna"
        case .Ecuador:
            titleDepartamento = "Selecciona una provincia"
            titleDistrito = "Busca una localidad/sector"
        case .Peru:
            titleDepartamento = "Selecciona un departamento"
            titleDistrito = "Busca un distrito"
        }
        
        if isRowCargandoHidden {
            switch section {
            case 0:
                return titleDepartamento
            case 1:
                return titleDistrito
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if Int(distritos[indexPath.row].ciu_id)! > 0 && Int(distritos[indexPath.row].cobertura)! == 1 {
                delegate?.ciudadDidSelect(ciudad: distritos[indexPath.row])
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - TextField
    @objc func distritoTextFieldDidChange(_ textField: UITextField) {
        if textField.text!.isEmpty {
            let distritosLastList = self.distritos
            
            self.distritos = []
            
            if distritosLastList.count != 0 {
                self.tableView.deleteSections(IndexSet(arrayLiteral: 2), with: .none)
            }
        } else if textField.text!.count >= 3 {
            if selectedIndexDepartamento >= 0 {
                fetchDistritosPorDepartamentoRequest(query: textField.text!)
            } else {
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                cell?.textLabel?.textColor = ColorPalette.Urbano.rojo
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func departamentoDidSelect(index: Int) {
        selectedIndexDepartamento = index
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
    func setupViews() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        tableView.register(UINib(nibName: "CargandoTableViewCell", bundle: nil), forCellReuseIdentifier: "cargandoCell")
        tableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "inputCell")
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToListaDepartamentos" {
            let vc = segue.destination as! ListaDepartamentosTableViewController
            vc.delegate = self
            vc.departamentos = departamentos
            vc.selectedIndexDepartamento = selectedIndexDepartamento
        }
    }
    
    func fetchDepartamentosRequest() {
        let params = FetchDepartamentosRequest(id: "0", idUsuario: "1")
        
        API.fetchDepartamentos(params: params) { (data, error) in
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
                    
                    self.departamentos = data.data
                    self.isRowCargandoHidden = true
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchDistritosPorDepartamentoRequest(query: String) {
        let params = FetchDistritosPorDepartamentoRequest(query: query,
                                                          idDepartamento: departamentos[selectedIndexDepartamento].id_dep,
                                                          lineaNegocio: "3",
                                                          idUsuario: "1")
        
        API.fetchDistritosPorDepartamento(params: params) { (data, error) in
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
                    
                    let distritosLastList = self.distritos
                    
                    self.distritos = data.data
                    
                    if distritosLastList.count == 0 {
                        self.tableView.insertSections(IndexSet(arrayLiteral: 2), with: .none)
                    } else {
                        self.tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .none)
                    }
                }
            }
        }
    }

}
