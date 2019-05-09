//
//  ImageUserObject.swift
//  VideoApp
//
//  Created by NM Cường on 13/07/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit

class ImageUserObject: NSObject {
    let id : String?
    let idImage : String?
    let link : String?
    
    init(id : String,idImage : String,link : String) {
        self.id = id
        self.idImage = idImage
        self.link = link
    }
}
