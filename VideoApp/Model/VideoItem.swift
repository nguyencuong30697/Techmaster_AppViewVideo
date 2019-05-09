//
//  VideoItem.swift
//  VideoApp
//
//  Created by NM Cường on 12/08/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import Foundation

class VideoItem: NSObject {
    let idVideo : String?
    let nameVideo : String?
    let linkVideo : String?
    var seenVideo : String?
    var likeVideo : String?
    let imageVideo : String?
    var timesVideo : Int?
    var timesPlayer : String?
    var timesContinues : Double?
    let typeVideo : String?
    let categoryVideo : String?
    
    init(id: String,name : String,link: String,seen : String,like : String,image : String,times : Int,timeplay : String,timecontinues : Double,typeVideo : String,categoryVideo : String) {
        self.idVideo = id
        self.nameVideo = name
        self.linkVideo = link
        self.seenVideo = seen
        self.likeVideo = like
        self.imageVideo = image
        self.timesVideo = times
        self.timesPlayer = timeplay
        self.timesContinues = timecontinues
        self.typeVideo = typeVideo
        self.categoryVideo = categoryVideo
    }
}
