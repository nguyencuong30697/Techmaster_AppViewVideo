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

@objcMembers class UserPlayerNew: Object {
    
    dynamic var id = UUID().uuidString
    dynamic var email : String = ""
    dynamic var fullname: String = ""
    dynamic var video : String = ""
    dynamic var likeVideo : String = ""
    dynamic var timesContinues : Double = 0
    dynamic var seen : String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    convenience init(name : String,link: String,seen : String,like : String,timecontinues :Double,seen1 : String) {
        self.init()
        self.email = name
        self.fullname = link
        self.video = seen
        self.likeVideo = like
        self.timesContinues = timecontinues
        self.seen = seen1
    }
}

extension UserPlayerNew {
    
    func SaveToUser(){
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
    
    static func getAllUserPlayer(in realm : Realm = try! Realm()) -> Results<UserPlayerNew> {
        return realm.objects(UserPlayerNew.self)
    }
    
    static func getVideoByUser(in realm : Realm = try! Realm(),seenCheck : String) -> Results<UserPlayerNew> {
        return realm.objects(UserPlayerNew.self).filter("seen IN %@", ["\(seenCheck)"])
    }
    
    static func getVideoByLikeUser(in realm : Realm = try! Realm(),likeCheck : String) -> Results<UserPlayerNew> {
        return realm.objects(UserPlayerNew.self).filter("likeVideo IN %@", ["\(likeCheck)"])
    }
    
    static func getVideoByEmail(in realm : Realm = try! Realm(),seenCheck : String) -> Results<UserPlayerNew> {
        return realm.objects(UserPlayerNew.self).filter("email IN %@", ["\(seenCheck)"])
    }
    
    func DeleteUser(){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    func UpdateSeen(s : String){
        let realm = try! Realm()
        try! realm.write {
            self.seen = s
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
}


