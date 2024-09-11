//
//  ListaDireccionesRVTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 25/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import GooglePlacePicker

class ListaDireccionesRVTableViewController: UITableViewController {
    
    var direcciones: [Direccion] = []
    
    struct Direccion {
        var idDireccion: String
        var distrito: String
        var direccion: String
        var referencia: String
        var idCiudad: String
        var latitude: String
        var longitude: String
        var selected: Bool
    }

    var indexPathButtonDidTap: IndexPath?
    
    var delegate: ListaDireccionesVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "DireccionRVTableViewCell", bundle: nil), forCellReuseIdentifier: "direccionCell")
        print("CREATE LISTA")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return direcciones.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "direccionCell", for: indexPath) as! DireccionRVTableViewCell
        cell.setupCell(direccion: direcciones[indexPath.row].direccion,
                       distrito: direcciones[indexPath.row].distrito,
                       referencia: direcciones[indexPath.row].referencia,
                       selected: direcciones[indexPath.row].selected)
        
        if cell.referenciaButton.gestureRecognizers?.count ?? 0 == 0 {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(referenciaButtonDidTap(_:)))
            cell.referenciaButton.addGestureRecognizer(tapGesture)
        }
        
        if cell.coordenadaButton.gestureRecognizers?.count ?? 0 == 0 {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(coordenadaButtonDidTap(_:)))
            cell.coordenadaButton.addGestureRecognizer(tapGesture)
        }
        
        if direcciones[indexPath.row].selected {
            print("SELECTED 1")
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DireccionRVTableViewCell
        cell.iconSelectorImage.image = UIImage(named: "ic_selector_selected_25pt")
        direcciones[indexPath.row].selected = true
        print("SELECTED 2")
        self.delegate?.distritoDidSelect(index: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? DireccionRVTableViewCell
        cell?.iconSelectorImage.image = UIImage(named: "ic_selector_unselected_25pt")
        direcciones[indexPath.row].selected = false
    }
    
    @objc func referenciaButtonDidTap(_ sender: UITapGestureRecognizer) {
        let indexPath = getIndexPathFromTapGestureRecognizer(gesture: sender)!
        
        let alert = UIAlertController(title: "Editar referencia", message: "Ingresa la referencia de la dirección.", preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Referencia"
            textField.clearButtonMode = UITextFieldViewMode.whileEditing
            
            if !self.direcciones[indexPath.row].referencia.isEmpty {
                textField.text = self.direcciones[indexPath.row].referencia
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (action:UIAlertAction) in
            
        }
        
        let saveAction = UIAlertAction(title: "Guardar", style: .default) { (action:UIAlertAction) in
            let referenciaTextField = alert.textFields![0] as UITextField
            
            self.direcciones[indexPath.row].referencia = referenciaTextField.text ?? ""
            self.delegate?.referenciaDidChange(index: indexPath.row, referencia: referenciaTextField.text ?? "")
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func coordenadaButtonDidTap(_ sender: UITapGestureRecognizer) {
        indexPathButtonDidTap = getIndexPathFromTapGestureRecognizer(gesture: sender)!
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    func showDirecciones(direcciones: [Direccion]) {
        self.direcciones = direcciones
        self.tableView.reloadData()
    }
    
    func getIndexPathFromTapGestureRecognizer(gesture: UITapGestureRecognizer) -> IndexPath? {
        guard let tappedView = gesture.view else {
            return nil
        }
        
        let touchPointInTableView = self.tableView.convert(tappedView.center, from: tappedView)
        guard let indexPath = self.tableView.indexPathForRow(at: touchPointInTableView) else {
            return nil
        }
        
        return indexPath
    }
    
    /*override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Dinos a que dirección llevaremos tu envío"
    }*/
}

extension ListaDireccionesRVTableViewController: GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        self.direcciones[indexPathButtonDidTap!.row].latitude = "\(place.coordinate.latitude)"
        self.direcciones[indexPathButtonDidTap!.row].longitude = "\(place.coordinate.longitude)"
        
        self.delegate?.coordenadaDidChange(index: indexPathButtonDidTap!.row,
                                           latitude: "\(place.coordinate.latitude)",
                                            longitude: "\(place.coordinate.longitude)")
        
        /*print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")*/
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
