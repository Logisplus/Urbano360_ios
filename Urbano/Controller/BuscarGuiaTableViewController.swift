//
//  BuscarGuiaTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import CoreLocation

class BuscarGuiaTableViewController: UITableViewController, UISearchBarDelegate  {
    
    var searchGuia: String?
    
    var searchTrackingRecord: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.autocapitalizationType = .allCharacters
        searchController.searchBar.placeholder = "Ingresa tu código de rastreo"
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .blackOpaque
        searchController.searchBar.barTintColor = .white
        //searchController.searchBar.backgroundColor = .green
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true;
        
        if #available(iOS 13.0, *) {
            //searchController.searchBar.searchTextField.backgroundColor = .white
            searchController.searchBar.searchTextField.textColor = .white
        }
        
        if let record = UserDefaultsManager.shared.searchTrackingRecord {
            searchTrackingRecord = record.reversed()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func barcodeButtonDidTap(_ sender: Any) {
        //present(ScannerViewController(), animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "ScannerBarcode", bundle: nil)
        let nav = storyboard.instantiateInitialViewController()! as! UINavigationController
        let vc = nav.viewControllers[0] as! ScannerBarcodeViewController
        vc.delegate = self
        present(nav, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchTrackingRecord.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        
        cell.textLabel?.text = searchTrackingRecord[indexPath.row]
        cell.imageView?.image = UIImage(named: "ic_busqueda_25pt")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchGuia = searchTrackingRecord[indexPath.row]
        self.performSegue(withIdentifier: "segueToRastrearEnvioVC", sender: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("shouldPerformSegue")
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToRastrearEnvioVC" {
            let vc = segue.destination as! RastrearEnvioViewController
            vc.searchGuia = self.searchGuia!
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchGuia = searchBar.text!
        self.performSegue(withIdentifier: "segueToRastrearEnvioVC", sender: nil)
        dismiss(animated: true, completion: nil)
        /*let vc = self.storyboard!.instantiateViewController(withIdentifier: "MapaEnvioStoryboard")
        show(vc, sender: nil)*/
    }

}

extension BuscarGuiaTableViewController: ScannerBarcodeViewDelegate {
    
    func barcodeDidRead(code: String) {
        searchGuia = code
        self.performSegue(withIdentifier: "segueToRastrearEnvioVC", sender: nil)
    }
    
}

class BuscarGuiaNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorPalette.Urbano.rojo
        
        navigationBar.barStyle = .blackOpaque
        navigationBar.barTintColor = ColorPalette.Urbano.rojo
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor.white
        navigationBar.backgroundColor = ColorPalette.Urbano.rojo
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
