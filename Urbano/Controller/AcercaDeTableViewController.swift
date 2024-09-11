//
//  AcercaDeTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 13/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class AcercaDeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        tableView.rowHeight = tableView.frame.height - 64.0
        tableView.register(UINib(nibName: "AcercaDeTableViewCell", bundle: nil), forCellReuseIdentifier: "acercaDeCell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "acercaDeCell", for: indexPath)

        return cell
    }

}
