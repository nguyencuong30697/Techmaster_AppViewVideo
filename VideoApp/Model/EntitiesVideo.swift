//
//  EntitiesVideo.swift
//  VideoApp
//
//  Created by NM Cường on 23/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//
import UIKit
import Foundation
import RealmSwift

@objcMembers class EntitiesVideoNewUpdate: Object {
    
    dynamic var idVideo = UUID().uuidString
    dynamic var nameVideo : String = ""
    dynamic var linkVideo: String = ""
    dynamic var seenVideo : String = ""
    dynamic var likeVideo : String = ""
    dynamic var imageVideo : String = ""
    dynamic var timesVideo : Int = 0
    dynamic var timesPlayer : String = ""
    dynamic var timesContinues : Double = 0
    dynamic var typeVideo : String = ""
    dynamic var categoryVideo : String = ""
    
    override static func primaryKey() -> String? {
        return "idVideo"
    }
    convenience init(id: String,name : String,link: String,seen : String,like : String,image : String,times : Int,timeplay : String,timecontinues : Double,typeVideo : String,categoryVideo : String) {
        self.init()
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

extension EntitiesVideoNewUpdate {
    
    func SaveToDataVideo(){
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
    
    static func getAllVideo(in realm : Realm = try! Realm()) -> Results<EntitiesVideoNewUpdate> {
        return realm.objects(EntitiesVideoNewUpdate.self)
    }
    
    static func getVideoBySeen(in realm : Realm = try! Realm(),seenCheck : String) -> Results<EntitiesVideoNewUpdate> {
        return realm.objects(EntitiesVideoNewUpdate.self).filter("seenVideo IN %@", ["\(seenCheck)"])
    }
    
    
    static func getVideoByLike(in realm : Realm = try! Realm(),likeCheck : String) -> Results<EntitiesVideoNewUpdate> {
        return realm.objects(EntitiesVideoNewUpdate.self).filter("likeVideo IN %@", ["\(likeCheck)"])
    }
    
    static func getVideoByName(in realm : Realm = try! Realm(),name : String) -> Results<EntitiesVideoNewUpdate> {
        return realm.objects(EntitiesVideoNewUpdate.self).filter("nameVideo IN %@", ["\(name)"])
    }
    
    static func getVideoBySearch(in realm : Realm = try! Realm(),name : String) -> Results<EntitiesVideoNewUpdate> {
        return realm.objects(EntitiesVideoNewUpdate.self).filter("nameVideo contains[c] %@", "\(name)")
    }
    
    func DeleteContact(){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    
    func UpdateTimes(timesVideo : Int){
        let realm = try! Realm()
        try! realm.write {
            self.timesVideo = timesVideo
        }
    }
    
    func UpdateSeen(){
        let realm = try! Realm()
        try! realm.write {
            self.seenVideo = "seen"
        }
    }
    
    func UpdateSeenAgain(){
        let realm = try! Realm()
        try! realm.write {
            self.seenVideo = "no"
        }
    }
    
    func UpdateLike(YN : String){
        let realm = try! Realm()
        try! realm.write {
            self.likeVideo = YN
        }
    }
    
    func UpdateTimeContimues(YN : Double){
        let realm = try! Realm()
        try! realm.write {
            self.timesContinues = YN
        }
    }
    
    func UpdateTimePlay(YN : String){
        let realm = try! Realm()
        try! realm.write {
            self.timesPlayer = YN
        }
    }
}

