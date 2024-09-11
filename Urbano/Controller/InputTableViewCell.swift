//
//  InputTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 26/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class InputTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var inputTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTextField.tintColor = RastrearEnvioViewController.PalleteColorUrbano.rojo
        inputTextField.delegate = self
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /*let tableView = self.superview as! UITableView
        let indexPath = tableView.indexPath(for: self)
        tableView.scrollToRow(at: indexPath!, at: .none, animated: true)*/
    }

}
