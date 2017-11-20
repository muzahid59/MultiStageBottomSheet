//
//  SheetCell.swift
//  MultiStageBottomSheet
//
//  Created by Muzahidul Islam on 11/20/17.
//  Copyright © 2017 Muzahidul Islam. All rights reserved.
//

import UIKit

class SheetCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
