//
//  ImageUser.swift
//  VideoApp
//
//  Created by NM Cường on 13/07/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ImageUser: UIViewController , UICollectionViewDataSource , UICollectionViewDelegate {

    @IBOutlet weak var tableImage: UICollectionView!
    @IBOutlet weak var btnDeleteImage: UIButton!
    @IBOutlet weak var btnAddImage: UIButton!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var activityy: UIActivityIndicatorView!
    var array:[ImageUserObject] = []
    var idImageDalete = Int()
    var stringNotification = String()
    var imgData : Data!
    var email : String! = nil
    var id : String! = nil
    var numberCellImgae : Int = 0
    var postDictValue : [String : AnyObject] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityy.startAnimating()
        // Do any additional setup after loading the view.
        let user = Auth.auth().currentUser
        if let user = user {
            // Get data in firebase
            id = user.uid
            email = user.email
            stringNotification = "Load Image Success"
            ref.child("UserImage").child(self.id!).observe(DataEventType.value, with: { (snapshot) in
                self.numberCellImgae = Int(snapshot.childrenCount)
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    let userDict = userSnap.value as! [String:AnyObject] //child data
                    let id = userDict["idImage"] as? String ?? "No Data"
                    let linkimage = userDict["linkImage"] as? String ?? "No Data"
                    let e = ImageUserObject(id: self.id!, idImage: id, link: linkimage)
                    self.array.append(e)
                }
                self.closeActivity()
                self.tableImage.reloadData()
                self.showAlert(message: self.stringNotification)
            })
        }else{
            showAlert(message: "Error")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of rows
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellImage", for: indexPath) as! CellImage
        let url = URL(string: array[indexPath.row].link!)
//                let data = try? Data(contentsOf: url!)
//                if let imageData = data {
//                    cell.ImageCellUser?.image = UIImage(data: imageData)
//                }
        cell.ImageCellUser?.loadImage(link: url!)
                cell.idImage = array[indexPath.row].idImage!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        idImageDalete = indexPath.row
        btnDeleteImage.isEnabled = true
    }
    
    @IBAction func AddImage(_ sender: Any) {
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
    
    @IBAction func DeleteImage(_ sender: Any) {
        runActivity()
        let idOfImage = array[idImageDalete].idImage
        ref.child("UserImage").child(self.id!).child(idOfImage!).removeValue()
        array.removeAll()
        stringNotification = "Delete Image Success"
        btnDeleteImage.isEnabled = false
    }
    
}

extension ImageUser : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let choiceImg = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        let imgValue = max(choiceImg.size.width, choiceImg.size.height)
        if (imgValue>3000){ // giam pixel tu 0.1 -> 1 de hien thi tot nhat
            imgData = choiceImg.jpegData(compressionQuality: 0.1)
        }else if (imgValue>2000){
            imgData = choiceImg.jpegData(compressionQuality: 0.3)
        }else{
            imgData = choiceImg.pngData()
        }
        runActivity()
        // Save In FireBase
        let idUser = id as String
        let idImage = UUID().uuidString
        var downloadURL : URL?
        let uploadTask = storageRef.child("imagesUser").child("\(idUser)").child("\(idImage).jpg").putData(self.imgData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                self.showAlert(message: "Error when upload Image")
                return
            }
            // You can also access to download URL after upload.
            let gsReference = storage.reference(forURL: "gs://appvideo-b841c.appspot.com/imagesUser/\(idUser)/\(idImage).jpg")
            gsReference.downloadURL { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                downloadURL = url
                let tableName = ref.child("UserImage")
                let userID = tableName.child(self.id!).child(idImage)
                let userFireBase : [String: AnyObject] = [
                    "idImage":idImage as String as AnyObject,
                    "linkImage":downloadURL!.absoluteString as String as AnyObject]
                userID.setValue(userFireBase)
                self.array.removeAll()
                self.stringNotification = "Add Image Success"
            }
        }
        uploadTask.resume()
        dismiss(animated: true, completion: nil)
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

extension UIImageView{ // Luc load anh cham no se co cai vong xoay de xoay
    func loadImage(link : URL){
        let quere: DispatchQueue = DispatchQueue(label: "LoadImage", attributes: DispatchQueue.Attributes.concurrent,target: nil)
        let activity: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        activity.frame = CGRect(x: self.frame.size.width/2, y: self.frame.size.height/2, width: 0, height: 0)
        activity.color = UIColor.blue
        self.addSubview(activity)
        activity.startAnimating()
        
        quere.async {
            do{
                let data : Data = try Data(contentsOf: link)
                DispatchQueue.main.async(execute: {
                    activity.stopAnimating()
                    self.image = UIImage(data: data)
                })
            }catch{
                print("Error Image")
            }
        }
    }
}
