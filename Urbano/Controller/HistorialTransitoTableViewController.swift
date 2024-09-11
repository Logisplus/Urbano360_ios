//
//  HistorialTransitoTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 14/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class HistorialTransitoTableViewController: UITableViewController {
    
    var responseRastrearEnvio: FetchEnvioResponse?
    var historialTransporte: [FetchEnvioResponse.Data.HistorialTransporte]?
    var sections: [String] = []
    var rows: [[FetchEnvioResponse.Data.HistorialTransporte]] = [[]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        navigationItem.backBarButtonItem = backItem
        
        historialTransporte = responseRastrearEnvio?.data[0].historialTransporte
        
        var rowsInSection: [FetchEnvioResponse.Data.HistorialTransporte] = []
        
        var index: Int = -1
        
        for historial in historialTransporte! {
            index = index + 1
            if sections.count == 0 {
                print("FECHA: \(historial.fecha)")
                sections.append(historial.fecha)
                rowsInSection.append(historial)
                
                if historialTransporte?.count == index + 1 {
                    rows.append(rowsInSection)
                    rowsInSection = []
                }
            } else {
                //if sections.contains(historial.fecha) {
                if sections[sections.count - 1] == historial.fecha {
                    print("FECHA: \(historial.fecha) 2")
                    rowsInSection.append(historial)
                    
                    if historialTransporte?.count == index + 1 {
                        rows.append(rowsInSection)
                        rowsInSection = []
                    }
                } else {
                    rows.append(rowsInSection)
                    rowsInSection = []
                    sections.append(historial.fecha)
                    print("FECHA: \(historial.fecha) 3")
                    rowsInSection.append(historial)
                    
                    if historialTransporte?.count == index + 1 {
                        rows.append(rowsInSection)
                        rowsInSection = []
                    }
                }
            }
        }
        
        /*for historial in historialTransporte! {
            index = index + 1
            if sections.count == 0 {
                print("FECHA: \(historial.fecha)")
                sections.append(historial.fecha)
                rowsInSection.append(historial)
                
                if historialTransporte?.count == index + 1 {
                    rows.append(rowsInSection)
                    rowsInSection = []
                }
            } else {
                if sections.contains(historial.fecha) {
                    print("FECHA: \(historial.fecha) 2")
                    rowsInSection.append(historial)
                    
                    if historialTransporte?.count == index + 1 {
                        rows.append(rowsInSection)
                        rowsInSection = []
                    }
                } else {
                    rows.append(rowsInSection)
                    rowsInSection = []
                    sections.append(historial.fecha)
                    print("FECHA: \(historial.fecha) 3")
                    rowsInSection.append(historial)
                    
                    if historialTransporte?.count == index + 1 {
                        rows.append(rowsInSection)
                        rowsInSection = []
                    }
                }
            }
        }*/
        
        rows.remove(at: 0)
        
        print("SECTIONS: \(sections.count)")
        print("ROWS SECTIONS: \(rows.count)")
        
        for s in rows {
            print("ROWS IN SECTIONS: \(s.count)")
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "HistorialTransitoViewCell", bundle: nil), forCellReuseIdentifier: "historialTransitoCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetalleVisitaTableViewController
        vc.eTracking = responseRastrearEnvio?.data[0].eTracking
        vc.movimientoGuia = rows[tableView.indexPathForSelectedRow!.section][tableView.indexPathForSelectedRow!.row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historialTransitoCell", for: indexPath) as! HistorialTransitoTableViewCell
        cell.tituloLabel.text = rows[indexPath.section][indexPath.row].motivo_movimiento
        cell.detalleLabel.text = rows[indexPath.section][indexPath.row].descripcion_movimiento.replacingOccurrences(of: "<br>", with: "\n")
        
        var hiddenLine: Bool = false
        if rows.count == indexPath.section + 1 && rows[rows.count - 1].count == indexPath.row + 1 {
            hiddenLine = true
        }
        
        if let idCHK = Int(rows[indexPath.section][indexPath.row].chk_id) {
            switch idCHK {
            case Constant.CHKControl.ENTREGADO :
                cell.cellStyleSetup(style: .color, bgColor: RastrearEnvioViewController.PalleteColorUrbano.negro, hiddenArrow: false, hiddenLine: hiddenLine)
            case Constant.CHKControl.NO_ENTREGADO, Constant.CHKControl.CLIENTE_VISITADO:
                cell.cellStyleSetup(style: .color, bgColor: RastrearEnvioViewController.PalleteColorUrbano.rojo, hiddenArrow: false, hiddenLine: hiddenLine)
            default:
                cell.cellStyleSetup(style: .default, bgColor: nil, hiddenArrow: true, hiddenLine: hiddenLine)
            }
        } else {
            cell.cellStyleSetup(style: .default, bgColor: nil, hiddenArrow: true, hiddenLine: hiddenLine)
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            cell.detalleLabel.text = rows[indexPath.section][indexPath.row].descripcion_movimiento.replacingOccurrences(of: "<br>", with: "\n")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.date(from: rows[indexPath.section][indexPath.row].hora) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "h:mm"
            let hour = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "a"
            let ampm = newDateFormatter.string(from: date)
            cell.horaLabel.text = hour
            cell.ampmLabel.text = ampm
        } else {
            cell.horaLabel.text = "hora"
            cell.ampmLabel.text = "am"
        }

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = HistorialTransitoTableViewHeader.instanceFromNib()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatter.date(from: sections[section]) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "dd"
            let day = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "EEEE"
            let dayName = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "MMMM"
            let monthName = newDateFormatter.string(from: date)
            newDateFormatter.dateFormat = "yyyy"
            let year = newDateFormatter.string(from: date)
            view.nibSetup(title: "\(dayName.capitalized), \(day) de \(monthName.capitalized) del \(year)")
        } else {
            view.nibSetup(title: "Fecha no definida")
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let idCHK = Int(rows[indexPath.section][indexPath.row].chk_id),
            (idCHK == Constant.CHKControl.ENTREGADO
                || idCHK == Constant.CHKControl.NO_ENTREGADO
                || idCHK == Constant.CHKControl.CLIENTE_VISITADO) {
                performSegue(withIdentifier: "segueFromHistorialTransitoToDetalleVisitaVC", sender: nil)
        }
    }

}
