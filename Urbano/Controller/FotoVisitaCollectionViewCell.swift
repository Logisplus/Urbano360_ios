//
//  FotoVisitaCollectionViewCell.swift
//  Urbano
//
//  Created by Mick VE on 16/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class FotoVisitaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
}
