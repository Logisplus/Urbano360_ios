//
//  BuscarDistritoTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 27/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class BuscarDistritoTableViewController: UITableViewController, UISearchBarDelegate {
    
    var lineaNegocio: String?
    
    var distritos: [FetchDistritosResponse.Distrito] = []
    
    var delegate: BuscarDistritoVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if #available(iOS 11.0, *) {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.tintColor = UIColor.white
            searchController.searchBar.autocapitalizationType = .sentences
            searchController.searchBar.placeholder = "Buscar"
            searchController.searchBar.delegate = self
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            self.definesPresentationContext = true;
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        return distritos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "distritoCell", for: indexPath)
        
        cell.textLabel?.text = distritos[indexPath.row].ciudad.capitalized

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // validar que el distrito seleccionado sea valido
        if let value = Int(distritos[indexPath.row].error_sql), value == 1 {
            self.delegate?.distritoDidSelect(distrito: distritos[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            fetchDistritos(query: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelarButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchDistritos(query: String) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        let params = FetchDistritosRequest(query: query,
                                           lineaNegocio: self.lineaNegocio!,
                                           idUsuario: "1")
        
        API.fetchDistritos(params: params) { (data, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
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
                }
                
                self.distritos = data!.data
                self.tableView.reloadData()
            }
        }
    }
}

class BuscarDistritoNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorPalette.Urbano.rojo
        
        navigationBar.barStyle = .blackOpaque
        navigationBar.barTintColor = ColorPalette.Urbano.rojo
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor.white
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
