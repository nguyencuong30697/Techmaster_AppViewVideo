//
//  CellImage.swift
//  VideoApp
//
//  Created by NM Cường on 13/07/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit

class CellImage: UICollectionViewCell {
    
    var id : Int = 0
    var idImage : String = "a"
    @IBOutlet weak var ImageCellUser:UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
