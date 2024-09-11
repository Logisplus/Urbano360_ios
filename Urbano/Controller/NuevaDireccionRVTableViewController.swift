//
//  NuevaDireccionRVTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 25/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import GooglePlacePicker

class NuevaDireccionRVTableViewController: UITableViewController {
    
    var lineaNegocio: String?
    
    var distrito: FetchDistritosResponse.Distrito?
    
    var location: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: "InputTableViewCell", bundle: nil), forCellReuseIdentifier: "inputCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            if let _ = distrito {
                cell.textLabel!.text = distrito!.ciudad.capitalized
            } else {
                cell.textLabel!.text = "Seleccionar un distrito"
            }
            return cell
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
                cell.inputTextField.keyboardType = .default
                cell.inputTextField.returnKeyType = .default
                cell.inputTextField.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
                cell.textLabel!.text = "Seleccionar una ubicación"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
            //cell.inputTextField.textContentType = UITextContentType.
            cell.inputTextField.keyboardType = .numberPad
            cell.inputTextField.returnKeyType = .default
            cell.inputTextField.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
            cell.inputTextField.keyboardType = .numberPad
            cell.inputTextField.returnKeyType = .default
            cell.inputTextField.delegate = self
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
            cell.inputTextField.keyboardType = .default
            cell.inputTextField.returnKeyType = .default
            cell.inputTextField.delegate = self
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BuscarDistritoStoryboard") as! UINavigationController
            let subVC = vc.viewControllers[0] as! BuscarDistritoTableViewController
            subVC.lineaNegocio = self.lineaNegocio!
            subVC.delegate = self
            self.present(vc, animated: true, completion: nil)
        case 1:
            if indexPath.row == 1 {
                let config = GMSPlacePickerConfig(viewport: nil)
                let placePicker = GMSPlacePickerViewController(config: config)
                
                placePicker.delegate = self
                
                present(placePicker, animated: true, completion: nil)
            }
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Distrito - Provincia - Departamento"
        case 1:
            return "Dirección"
        case 2:
            return "Nro. Puerta"
        case 3:
            return "Nro. Interior"
        case 4:
            return "Referencia"
        default:
            return "No definido"
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 4 ? "Importante: para una entrega efectiva, detalla correctamente los pasos para llegar al lugar." : ""
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func validateDatos() -> Bool {
        guard let _ = distrito else {
            return false
        }
        
        // validar direccion
        var cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
        if let value = cell.inputTextField.text, value.count == 0 {
            return false
        }
        
        // validar nro. puerta
        cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! InputTableViewCell
        if let value = cell.inputTextField.text, value.count == 0 {
            return false
        }
        
        return true
    }
    
    func getDataNuevaDireccion() -> [String: String] {
        let cellDireccion = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
        let cellNroPuerta = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! InputTableViewCell
        let cellNroInterior = self.tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! InputTableViewCell
        let cellReferencia = self.tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as! InputTableViewCell
        
        return [
            "idCiudad": distrito!.ciu_id,
            "direccion": cellDireccion.inputTextField.text!,
            "latitude": self.location != nil ? "\(self.location!.latitude)" : "",
            "longitude": self.location != nil ? "\(self.location!.longitude)" : "",
            "nroPuerta": cellNroPuerta.inputTextField.text!,
            "nroInterior": cellNroInterior.inputTextField.text ?? "",
            "referencia": cellReferencia.inputTextField.text ?? ""
        ]
    }

}

extension NuevaDireccionRVTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension NuevaDireccionRVTableViewController: BuscarDistritoVCDelegate {
    
    func distritoDidSelect(distrito: FetchDistritosResponse.Distrito) {
        self.distrito = distrito
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.textLabel?.text = distrito.ciudad.capitalized
    }
    
}

extension NuevaDireccionRVTableViewController: GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! InputTableViewCell
        
        cell.inputTextField.text = place.name
        
        self.location = place.coordinate
        
        /*print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")*/
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
