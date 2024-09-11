//
//  CargandoTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 22/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class CargandoTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
