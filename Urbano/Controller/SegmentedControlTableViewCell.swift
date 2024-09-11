//
//  SegmentedControlTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 27/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class SegmentedControlTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.segmentedControl.tintColor = ColorPalette.Urbano.rojo
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
