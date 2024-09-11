//
//  TextViewTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 1/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.tintColor = ColorPalette.Urbano.rojo
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
