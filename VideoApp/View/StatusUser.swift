//
//  StatusUser.swift
//  VideoApp
//
//  Created by NM Cường on 27/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import RealmSwift
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

var ref: DatabaseReference! = Database.database().reference()
var currentUser : User!
var arrayVideo:[VideoItem] = []
var idOfUser : String!


class StatusUser: UIViewController , allVideoDeleGate{
    
    private var itemsUserInfo: Results<UserInfoNew>?
    
    
    @IBOutlet weak var viewAll: UIView!
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var btnViewVideo: UIButton!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var txtText: UITextView!
    @IBOutlet weak var txtNameUser: UILabel!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var age: UITextField!
    @IBOutlet weak var videoLike: UITextField!
    @IBOutlet weak var videoSeen: UITextField!
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var activityy: UIActivityIndicatorView!
    
    var email : String! = nil
    var id : String! = nil
    var imgData : Data!
    
    func allUser(_ controller: ViewController,email : String) {
        ref.child("UserList").child(self.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? [String : AnyObject]
            let videoLike12 = value?["videoLike"] as? Int ?? 0
            let videoSeen12 = value?["videoSeen"] as? Int ?? 0
            self.videoLike.text = "\(videoLike12)"
            self.videoSeen.text = "\(videoSeen12)"
            self.navigationController?.popViewController(animated:true)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private var itemsUser: Results<UserPlayerNew>?
    @IBOutlet weak var ImageFace: UIImageView!
    var check : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewStatus()
        runActivity()
        let user = Auth.auth().currentUser
        if let user = user {
            // Get data in firebase
            id = user.uid
            email = user.email
            idOfUser = id
            self.getDataInFireBase(id : user.uid,email: user.email!,photoURL: user.photoURL!,nameUser : user.displayName!)
            ///
            self.closeActivity()
            self.showAlert(message: "Login Successful")
            /// Save data in realm . Boi vi so luong nguoi dung cua mot may la ko nhieu nen luu vào realm dc .
//            itemsUser = UserPlayerNew.getAllUserPlayer()
//            if(itemsUser?.count == 0){
//            }else{
//                for k: Int in 0...(itemsUser?.count)!-1{
//                    if (itemsUser![k].email == email){
//                        check = false
//                        return
//                    }
//                }
//            }
//            if check {
//                UserPlayerNew(name: email!, link: "", seen: "", like: "", timecontinues: 0.0, seen1: "no").SaveToUser()
//            }
//            //
        }else{
            closeActivity()
            showAlert(message: "Error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signout(_ sender: Any) {
        let alert = UIAlertController(title: "Sign Out", message: "Are You Sure!!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
            try! Auth.auth().signOut()
            try! GIDSignIn.sharedInstance().signOut()
            try! FBSDKLoginManager().logOut()
            self.navigationController?.popToRootViewController(animated: true) }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveData(_ sender: Any) {
        // Save in Firebase
        ref.child("UserList").child(self.id!).updateChildValues([
            "fullName": fullName.text ?? "No Data",
            "age":age.text ?? "No Data",
            "phone":phone.text ?? "No Data",
            "gender":gender.selectedSegmentIndex,
            "information": txtText.text ?? "No Data"
        ])
        showAlert(message: "Save Success !")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allVideo" {
            let controller = segue.destination as! ViewController
            controller.delegate = self
            controller.emailUser = self.email
            controller.idUserToGetCell1 = self.id
        }
    }
}

extension StatusUser : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let choiceImg = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        let imgValue = max(choiceImg.size.width, choiceImg.size.height)
        if (imgValue>3000){ // giam pixel tu 0.1 -> 1
            imgData = choiceImg.jpegData(compressionQuality: 0.1)
        }else if (imgValue>2000){
            imgData = choiceImg.jpegData(compressionQuality: 0.3)
        }else{
            imgData = choiceImg.pngData()
        }
        runActivity()
        let Sss = email as String
        let desertRef = storageRef.child("images").child("\(Sss).jpg")
        // Delete the file
        desertRef.delete { error in
            if let error = error {
                self.closeActivity()
                self.showAlert(message: error.localizedDescription)
                // Uh-oh, an error occurred!
            } else {
                // Save In FireBase
                var downloadURL : URL?
                let uploadTask = storageRef.child("images").child("\(Sss).jpg").putData(self.imgData, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                        self.showAlert(message: "Error when upload Image")
                        return
                    }
                    // You can also access to download URL after upload.
                    let gsReference = storage.reference(forURL: "gs://appvideo-b841c.appspot.com/images/\(Sss).jpg")
                    gsReference.downloadURL { (url, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        downloadURL = url
                        ref.child("UserList").child(self.id!).updateChildValues([
                            "linkImageFace": downloadURL?.absoluteString ?? "No data"
                            ])
                        self.closeActivity()
                        self.imageUser.image = UIImage(data: self.imgData)
                        self.showAlert(message: "Change ImageFace Success !")
                    }
                }
                uploadTask.resume()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ChangeImage() {
        let alter : UIAlertController = UIAlertController(title: "🚀 Notification", message: "Change Image By", preferredStyle: .alert)
        let btnPhoto : UIAlertAction = UIAlertAction(title: "Photo", style: .default) { (UIAlertAction) in
            let imgPicker = UIImagePickerController()
            imgPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imgPicker.delegate = self
            imgPicker.allowsEditing = false
            self.present(imgPicker, animated: true, completion: nil)
        }
        let btnCamera : UIAlertAction = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            if (UIImagePickerController.isSourceTypeAvailable(.camera)){ // Kiem tra xem co camera ko
                let imgPicker = UIImagePickerController()
                imgPicker.sourceType = UIImagePickerController.SourceType.camera
                imgPicker.delegate = self
                imgPicker.allowsEditing = false
                self.present(imgPicker, animated: true, completion: nil)
            }else{
                // De alter ko co camera
                self.showAlert(message: "Don't have Camera")
            }
        }
        alter.addAction(btnPhoto)
        alter.addAction(btnCamera)
        self.present(alter, animated: true, completion: nil)
    }
    
    func loadViewStatus(){
        viewAll.layer.cornerRadius = 15
        viewAll.backgroundColor = UIColor(red: 191.0/255, green: 191.0/255, blue: 191.0/255, alpha: 0.6)
        imageUser.layer.cornerRadius = imageUser.bounds.size.width / 2
        imageUser.layer.masksToBounds = true
        imageUser.isUserInteractionEnabled = true
        let tagGesture = UITapGestureRecognizer(target: self, action: #selector(self.ChangeImage))
        imageUser.addGestureRecognizer(tagGesture)
    }
    
    func showValueUI(email : String,fullname : String,age : String,phone : String,videoLike : Int,videoSeen : Int,gender : Int,information : String,name : String,imagelink : String){
        self.mail.text = email
        self.fullName.text = fullname
        self.age.text = age
        self.phone.text = phone
        self.videoLike.text = "\(videoLike)"
        self.videoSeen.text = "\(videoSeen)"
        self.txtText.text = information
        self.txtNameUser.text = name
        self.gender.selectedSegmentIndex = gender
        let url = URL(string: imagelink)
        imageUser.loadImage(link: url!)
//        let data = try? Data(contentsOf: url!)
//        if let imageData = data {
//            imageUser.image = UIImage(data: imageData)
//        }
    }
    
    func getDataInFireBase(id : String,email: String,photoURL: URL,nameUser : String){
        ref.child("UserList").child(self.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? [String : AnyObject] {
                let email = value["email"] as? String ?? "No Data"
                let name = value["name"] as? String ?? "No Data"
                let imagelink = value["linkImageFace"] as? String ?? "No Data"
                let fullName = value["fullName"] as? String ?? "No Data"
                let age = value["age"] as? String ?? "No Data"
                let phone = value["phone"] as? String ?? "No Data"
                let videoLike = value["videoLike"] as? Int ?? 0
                let videoSeen = value["videoSeen"] as? Int ?? 0
                let gender = value["gender"] as? Int ?? 0
                let information = value["information"] as? String ?? "No Data"
                self.showValueUI(email: email, fullname: fullName, age: age, phone: phone, videoLike: videoLike, videoSeen: videoSeen, gender: gender, information: information, name: name,imagelink : imagelink)
            }else{
                currentUser  = User(id: id, email: self.email, name: nameUser, imageUser: (photoURL.absoluteString) ,fullname: "No Data", age: "No Data", phone: "No Data", videoLike: 0, videoSeen: 0, gender: 0, information: "No Data")
                let tableName = ref.child("UserList")
                let userID = tableName.child(self.id!)
                let userFireBase : [String: AnyObject] = [
                    "email":currentUser.email as String as AnyObject,
                    "name":currentUser.name as String as AnyObject,
                    "linkImageFace":currentUser.linkImageFace as String as AnyObject,
                    "fullName":currentUser.fullName as String as AnyObject,
                    "age":currentUser.age as String as AnyObject,
                    "phone":currentUser.phone as String as AnyObject,
                    "videoLike":currentUser.videoLike as Int as AnyObject,
                    "videoSeen":(currentUser.videoSeen) as Int as AnyObject,
                    "gender":(currentUser.gender) as Int as AnyObject,
                    "information":currentUser.information as String as AnyObject]
                userID.setValue(userFireBase)
                ref.child("UserList").child(self.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? [String : AnyObject]
                    let email = value?["email"] as? String ?? "No Data"
                    let name = value?["name"] as? String ?? "No Data"
                    let imagelink = value?["linkImageFace"] as? String ?? "No Data"
                    let fullName = value?["fullName"] as? String ?? "No Data"
                    let age = value?["age"] as? String ?? "No Data"
                    let phone = value?["phone"] as? String ?? "No Data"
                    let videoLike = value?["videoLike"] as? Int ?? 0
                    let videoSeen = value?["videoSeen"] as? Int ?? 0
                    let gender = value?["gender"] as? Int ?? 0
                    let information = value?["information"] as? String ?? "No Data"
                    self.showValueUI(email: email, fullname: fullName, age: age, phone: phone, videoLike: videoLike, videoSeen: videoSeen, gender: gender, information: information, name: name,imagelink : imagelink)
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }) {
            (error) in
            print(error.localizedDescription)
        }
    }
    
    func runActivity(){
        viewActivity.isHidden = false
        activityy.isHidden = false
        activityy.startAnimating()
    }
    
    func closeActivity(){
        activityy.stopAnimating()
        viewActivity.isHidden = true
        activityy.isHidden = true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
