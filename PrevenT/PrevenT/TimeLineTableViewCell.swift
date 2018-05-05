//
//  TimeLineTableViewCell.swift
//  PrevenT
//
//  Created by Beto Farias on 12/25/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {
    
    @IBOutlet var imgIco: UIImageView!;
    @IBOutlet var txtTitulo: UILabel!;
    @IBOutlet var txtFecha: UILabel!;
    @IBOutlet var txtNumLikes: UILabel!;
    @IBOutlet var txtDireccion: DesignableLabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
