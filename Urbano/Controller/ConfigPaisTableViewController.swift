//
//  ConfigPaisTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 16/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class ConfigPaisTableViewController: UITableViewController {

    var countries = [CountryRow]()
    
    struct CountryRow {
        var id: API.Country
        var name: String
        var image: UIImage?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60
        
        setupCountries()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueConfigPaisToPoliticas" {
            let vc = segue.destination as! PoliticasViewController
            vc.country = self.countries[self.tableView.indexPathForSelectedRow!.row].id
        }
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
        cell.imageView!.layer.cornerRadius = 5
        cell.imageView!.clipsToBounds = true
        cell.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueConfigPaisToPoliticas", sender: nil)
    }
    
    func setupCountries() {
        countries = [
            CountryRow(id: API.Country.Chile, name: "Chile", image: UIImage(named: "ic_flag_chile_25pt")),
            CountryRow(id: API.Country.Ecuador, name: "Ecuador", image: UIImage(named: "ic_flag_ecuador_25pt")),
            CountryRow(id: API.Country.Peru, name: "Perú", image: UIImage(named: "ic_flag_peru_25pt"))]
    }
    
    func setupDefaultCountry() {
        let locale: Locale = Locale.current as Locale
        switch locale.regionCode!.uppercased() {
        case "CL":
            print("select chile")
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        case "EC":
            print("select ecuador")
            tableView.selectRow(at: IndexPath(row: 1, section: 0), animated: true, scrollPosition: .none)
        case "PE":
            print("select peru")
            tableView.selectRow(at: IndexPath(row: 2, section: 0), animated: true, scrollPosition: .none)
        default:
            break
        }
    }

}
