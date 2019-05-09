//
//  LoginController.swift
//  VideoApp
//
//  Created by NM Cường on 27/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginController: UIViewController , FBSDKLoginButtonDelegate, GIDSignInUIDelegate,GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // cai nay de luu len firebase
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil {
                // ...
                return
            }
            // User is signed in
            // ...
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "statusUser") as! StatusUser
            self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if FBSDKAccessToken.current() != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if error != nil {
                    // ...
                    return
                }
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "statusUser") as! StatusUser
                self.navigationController?.pushViewController(myVC, animated: true)
            }
        }
    }
    
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtpass: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var activityy: UIActivityIndicatorView!
    @IBOutlet weak var viewFB: UIView!
    @IBOutlet weak var viewGG: UIView!
    
    let signInButton = GIDSignInButton()
    let loginButton = FBSDKLoginButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadView()
        try! Auth.auth().signOut() // Logout tat ca ra
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        // Do any additional setup after loading the view.
        loginButton.readPermissions = ["email"]
        loginButton.delegate = self
        loginButton.frame = CGRect(x: 0, y: 0, width: viewFB.bounds.size.width , height: viewFB.bounds.size.height)
        viewFB.addSubview(loginButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        signInButton.frame = CGRect(x: -4, y: -4, width: viewGG.bounds.size.width+8 , height: viewGG.bounds.size.height)
        viewGG.addSubview(signInButton)
    }

    @IBAction func Login(_ sender: Any) {
        runActivity()
        Auth.auth().signIn(withEmail: txtEmail.text!, password: txtpass.text!) { (user, error) in
            // ...
            if (error == nil){
                self.closeActivity()
                self.resetTextField()
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "statusUser") as! StatusUser
                self.navigationController?.pushViewController(myVC, animated: true)
            }else{
                self.closeActivity()
                self.showAlert(message: "User or Password was wrong !")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension LoginController{
    func LoadView(){
        viewLogin.backgroundColor = UIColor(red: 225.0/255.0 , green: 224.0/255.0, blue: 179.0/255.0, alpha: 0.6)
        viewLogin.layer.cornerRadius = 10
        btnLogin.backgroundColor = UIColor.blue
        btnRegister.backgroundColor = UIColor.blue
        btnLogin.layer.cornerRadius = 5
        btnRegister.layer.cornerRadius = 5
        viewActivity.layer.cornerRadius = 10
        viewActivity.isHidden = true
        activityy.isHidden = true
    }
    
    func resetTextField(){
        txtEmail.text = ""
        txtpass.text = ""
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
