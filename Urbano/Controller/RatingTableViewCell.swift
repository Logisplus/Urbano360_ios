//
//  RatingTableViewCell.swift
//  Urbano
//
//  Created by Mick VE on 2/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var floatRatingView: FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        floatRatingView.type = .wholeRatings
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
