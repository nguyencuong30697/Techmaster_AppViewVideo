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

@objcMembers class UserInfoNew: Object {
    
    dynamic var id = UUID().uuidString
    dynamic var email : String = ""
    dynamic var name : String = ""
    dynamic var phone : String = ""
    dynamic var des : String = ""
    dynamic var image : Data?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    convenience init(email : String,name :String,phone: String,des : String,image : Data) {
        self.init()
        self.email = email
        self.name = name
        self.phone = phone
        self.des = des
        self.image = image
    }
}

extension UserInfoNew {
    
    func SaveToUser(){
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
    
    static func getUserInfo(in realm : Realm = try! Realm()) -> Results<UserInfoNew> {
        return realm.objects(UserInfoNew.self)
    }
    
    static func getVideoByUser(in realm : Realm = try! Realm(),email : String) -> Results<UserInfoNew> {
        return realm.objects(UserInfoNew.self).filter("email IN %@", ["\(email)"])
    }
    
    func DeleteUser(){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    func DeleteAll(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func UpdatePhone(s : String){
        let realm = try! Realm()
        try! realm.write {
            self.phone = s
        }
    }
    
    func UpdateDes(YN : String){
        let realm = try! Realm()
        try! realm.write {
            self.des = YN
        }
    }
}



