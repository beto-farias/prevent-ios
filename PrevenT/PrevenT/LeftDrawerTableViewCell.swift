//
//  LeftDrawerTableViewCell.swift
//  PrevenT
//
//  Created by Beto Farias on 11/9/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class LeftDrawerTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var txtMenuOpcion: UILabel!
    @IBOutlet weak var sideMenuItemIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
