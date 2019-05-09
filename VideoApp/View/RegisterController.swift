//
//  RegisterControllerViewController.swift
//  VideoApp
//
//  Created by NM Cường on 27/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

var storage = Storage.storage()// Bien toan cuc
let storageRef = storage.reference()
//forURL:"gs://appvideo-b841c.appspot.com"


class RegisterControllerViewController: UIViewController{

    var imgData : Data!
    @IBOutlet weak var viewRegister: UIView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var txtNameUser: UITextField!
    @IBOutlet weak var ImageFace: UIImageView!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var activityy: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadDesignView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                // Show alter ko co camera
                self.showAlert(message: "Don't have Camera")
            }
        }
        alter.addAction(btnPhoto)
        alter.addAction(btnCamera)
        self.present(alter, animated: true, completion: nil)
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        
        if self.checkValid(){
            let user = txtUsername.text!
            let pass = txtPassword.text!
            runActivity()
            Auth.auth().createUser(withEmail: user, password: pass) { (authResult, error) in
                if (error == nil){
                    Auth.auth().signIn(withEmail: user, password: pass) { (user, error) in
                        // ...
                    }
                    //Save in Realms
                    UserInfoNew(email: user, name : self.txtNameUser.text!,phone: "No Data" , des: "No Data", image: self.imgData).SaveToUser()
                    //Create link save photo Image
                    let uploadTask = storageRef.child("images").child("\(user).jpg").putData(self.imgData, metadata: nil) { (metadata, error) in
                        guard metadata != nil else {
                            self.showAlert(message: "Error when upload Image")
                            return
                        }
                        //You can also access to download URL after upload.
                        print("OK")
                        var downloadURL : URL?
                        let gsReference = storage.reference(forURL: "gs://appvideo-b841c.appspot.com/images/\(user).jpg")
                        gsReference.downloadURL { (url, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                                return
                            }
                            downloadURL = url
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.displayName = self.txtNameUser.text!
                            changeRequest?.photoURL = downloadURL
                            changeRequest?.commitChanges { (error) in
                                if (error==nil){
                                    self.closeActivity()
                                    self.resetUI()
                                    let myVC = self.storyboard?.instantiateViewController(withIdentifier: "statusUser") as! StatusUser
                                    self.navigationController?.pushViewController(myVC, animated: true)
                                }else{
                                    self.closeActivity()
                                    self.resetUI()
                                    self.showAlert(message: "Error when Commit")
                                }
                            }
                        }
                    }
                    uploadTask.resume()
                }else{
                    self.closeActivity()
                    self.resetUI()
                    self.showAlert(message: "Error when Register")
                }
            }
        }else{
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar for current view controller
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.isNavigationBarHidden = false;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension RegisterControllerViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
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
        ImageFace.image = UIImage(data: imgData)
        dismiss(animated: true, completion: nil)
    }
    
    func LoadDesignView(){
        ImageFace.layer.cornerRadius = ImageFace.bounds.size.width/2
        ImageFace.layer.masksToBounds = true
        ImageFace.isUserInteractionEnabled = true
        let tagGesture = UITapGestureRecognizer(target: self, action: #selector(self.ChangeImage))
        ImageFace.addGestureRecognizer(tagGesture)
        viewRegister.backgroundColor = UIColor(red: 230.0/255.0 , green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.6)
        viewRegister.layer.cornerRadius = 10
        imgData = UIImage(named: "camera")!.pngData() // set gia tri mac dinh
        viewActivity.layer.cornerRadius = 10
        viewActivity.isHidden = true
        activityy.isHidden = true
        txtUsername.keyboardType = .emailAddress //Keyboard show @ like "Email address"
        txtUsername.autocorrectionType = .no
        txtUsername.autocapitalizationType = .none
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
    
    func resetUI(){
        txtNameUser.text = ""
        txtPassword.text = ""
        txtUsername.text = ""
        txtConfirmPass.text = ""
        ImageFace.image = #imageLiteral(resourceName: "camera")
    }
    
    func checkValid() -> Bool{
        let predicate = NSPredicate(format: "SELF MATCHES %@",
                                    "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        if predicate.evaluate(with: txtUsername.text!) == false {
            self.showAlert(message: "📌 Email Is Invalid")
            return false
        }
        if(txtPassword.text! != txtConfirmPass.text!){
            self.showAlert(message: "📌 Check Password Again")
            return false
        }
        if(txtPassword.text! == ""){
            self.showAlert(message: "📌 Password Isn't Blank")
            return false
        }
        if(txtNameUser.text! == ""){
            self.showAlert(message: "📌 Name Isn't Blank")
            return false
        }
        return true
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
