//
//  CambiarDePaisTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 13/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class CambiarDePaisTableViewController: UITableViewController {
    
    var countries = [CountryRow]()
    
    struct CountryRow {
        var id: API.Country
        var name: String
        var image: UIImage?
        var selected: Bool
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.rowHeight = 60
        
        setupCountries()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        
        cell.textLabel?.text = countries[indexPath.row].name
        cell.textLabel?.numberOfLines = 0
        cell.imageView?.image = countries[indexPath.row].image
        cell.imageView?.layer.cornerRadius = 5
        cell.imageView?.clipsToBounds = true
        cell.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
        
        if countries[indexPath.row].selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .checkmark
        countries[indexPath.row].selected = true
        
        UserDefaultsManager.shared.country = countries[indexPath.row].id
        UserDefaultsManager.shared.searchTrackingRecord = nil
        
        NetworkManager.shared().buildAPI(country: countries[indexPath.row].id.rawValue)
        
        UserSession.logout()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .none
        countries[indexPath.row].selected = false
    }
    
    func setupCountries() {
        countries = [
            CountryRow(id: API.Country.Chile, name: "Chile", image: UIImage(named: "ic_flag_chile_25pt"),
                       selected: UserDefaultsManager.shared.country == API.Country.Chile),
            CountryRow(id: API.Country.Ecuador, name: "Ecuador", image: UIImage(named: "ic_flag_ecuador_25pt"),
                       selected: UserDefaultsManager.shared.country == API.Country.Ecuador),
            CountryRow(id: API.Country.Peru, name: "Perú", image: UIImage(named: "ic_flag_peru_25pt"),
                       selected: UserDefaultsManager.shared.country == API.Country.Peru)]
    }

}
