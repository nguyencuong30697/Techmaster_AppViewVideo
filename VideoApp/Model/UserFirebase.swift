//
//  File.swift
//  VideoApp
//
//  Created by NM Cường on 27/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import Foundation

struct User {
    let id : String!
    let email : String!
    let name : String!
    let linkImageFace : String!
    let fullName : String!
    let age : String!
    let phone : String!
    let videoLike : Int!
    let videoSeen : Int!
    let gender : Int!
    let information : String!
    
    init() {
        self.id = ""
        self.email = ""
        self.name = ""
        self.linkImageFace = ""
        self.fullName = ""
        self.age = ""
        self.phone = ""
        self.videoLike = 0
        self.videoSeen = 0
        self.gender = 0
        self.information = ""
    }
    
    init(id : String,email : String,name : String,imageUser : String,fullname : String,age : String,phone : String,videoLike : Int,videoSeen : Int,gender : Int,information : String) {
        self.id = id
        self.email = email
        self.name = name
        self.linkImageFace = imageUser
        self.fullName = fullname
        self.age = age
        self.phone = phone
        self.videoLike = videoLike
        self.videoSeen = videoSeen
        self.gender = gender
        self.information = information
    }
}
