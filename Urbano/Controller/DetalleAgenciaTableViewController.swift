//
//  DetalleAgenciaTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 6/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import MessageUI

class DetalleAgenciaTableViewController: UITableViewController {
    
    var agencia: Localizanos.FetchAgenciasUrbano.Response.Agencias?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "DetalleAgenciaTableViewCell", bundle: nil), forCellReuseIdentifier: "detalleAgenciaCell")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detalleAgenciaCell", for: indexPath) as! DetalleAgenciaTableViewCell
        
        cell.setupDetalleAgencia(agencia: agencia!)
        
        return cell
    }
    
}
