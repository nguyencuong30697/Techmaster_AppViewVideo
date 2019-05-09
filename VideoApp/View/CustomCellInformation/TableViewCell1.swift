//
//  TableViewCell1.swift
//  VideoApp
//
//  Created by NM Cường on 07/10/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit

class TableViewCell1: UITableViewCell {

    @IBOutlet weak var imageCell1: UIImageView!
    @IBOutlet weak var labelCell1: UILabel!
    
    func loadImage(){
        imageCell1.layer.cornerRadius = imageCell1.bounds.size.width / 2
        imageCell1.layer.masksToBounds = true
        imageCell1.isUserInteractionEnabled = true
    }
}
