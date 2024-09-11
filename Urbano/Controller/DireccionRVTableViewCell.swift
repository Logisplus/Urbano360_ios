//
//  DireccionRVTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 25/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class DireccionRVTableViewCell: UITableViewCell {

    @IBOutlet weak var referenciaButton: UIButton!
    @IBOutlet weak var coordenadaButton: UIButton!
    @IBOutlet weak var direccionLabel: UILabel!
    @IBOutlet weak var distritoLabel: UILabel!
    @IBOutlet weak var referenciaLabel: UILabel!
    @IBOutlet weak var iconSelectorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButton(button: referenciaButton)
        setupButton(button: coordenadaButton)
        
        direccionLabel.textColor = ColorPalette.Urbano.negro
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        referenciaButton.backgroundColor = ColorPalette.Urbano.gris
        coordenadaButton.backgroundColor = ColorPalette.Urbano.gris
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        referenciaButton.backgroundColor = ColorPalette.Urbano.gris
        coordenadaButton.backgroundColor = ColorPalette.Urbano.gris
    }
    
    @IBAction func referenciaButtonDidTap(_ sender: Any) {
        let indexPath = (self.superview as! UITableView).indexPath(for: self)
        //print("\(indexPath?.row)")
    }
    
    func setupButton(button: UIButton) {
        button.tintColor = UIColor.white
        button.backgroundColor = ColorPalette.Urbano.gris
        button.layer.cornerRadius = button.frame.height / 2
    }
    
    func setupCell(direccion: String, distrito: String, referencia: String, selected: Bool) {
        direccionLabel.text = direccion
        distritoLabel.text = distrito
        referenciaLabel.text = referencia.isEmpty ? "Ref.: No hay referencia." : "Ref.: \(referencia)"
        
        if selected {
            iconSelectorImage.image = UIImage(named: "ic_selector_selected_25pt")
        } else {
            iconSelectorImage.image = UIImage(named: "ic_selector_unselected_25pt")
        }
    }

}
