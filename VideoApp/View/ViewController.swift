//
//  ViewController.swift
//  VideoApp
//
//  Created by NM Cường on 23/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import AVKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


var countLike : Int = 0
var countSeen : Int = 0
var checkViewMenu : Bool = true
//bien toan cuc

protocol allVideoDeleGate: class {
    func allUser(_ controller: ViewController,email : String)
}

class ViewController: UIViewController , CellDelagate , VideoDeleGate {
    
    weak var delegate: allVideoDeleGate?
    private var itemsUserOld: Results<UserPlayerNew>?
    private var itemsUser: Results<UserPlayerNew>?
    private var itemsUserLike: Results<UserPlayerNew>?
    private var itemsUserSeen: Results<UserPlayerNew>?
    private var itemsTemp: Results<EntitiesVideoNewUpdate>?
    private var itemsAllSearch: Results<EntitiesVideoNewUpdate>?
    private var itemsToken: NotificationToken?
    
    //check bunnton
    var checkStatusButton : String = "1"
    
    var emailUser : String = ""
    var idUserToGetCell1 : String = ""
    var indexArray = Int()
    
    //Sau khi xem xong quay ve List Video
    func ListReadLoad(_ controller: ViewVideo) {
        arrayVideoFirst = arrayVideo
        if (checkStatusButton == "1"){
            
        }else if (checkStatusButton == "2"){
            arrayVideo = arrayVideo.filter { ($0.seenVideo?.contains("yes"))! }
        }else{
            arrayVideo = arrayVideo.filter { ($0.likeVideo?.contains("yes"))! }
        }
        tbl.reloadData()
        navigationController?.popViewController(animated:true)
    }
    
    
    @IBAction func ShowInfo(_ sender: Any) {
        if (viewMenu.frame.origin.x<0){ // Xet xem no co hien len tren man hinh ko
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.x += self.view.frame.width/2
                self.view.frame.origin.x += self.view.frame.width/2
            }
        }else{
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.x -= self.view.frame.width/2
                self.view.frame.origin.x -= self.view.frame.width/2
            }
        }
    }
    
    //
    var viewMenu : UIView = UIView()
    var tblView123 : UITableView = UITableView()
    var arrayMenu : Array<String> = ["linkImage","Full Name :","Age :","Number Phone :"]
    var nameOfUserCell : String = ""
    var arrayMenuInfo : Array<String> = []
    //
    @IBAction func User(_ sender: Any) {
        // Xet xem no co hien len tren man hinh ko neu co thi minh dong no lai roi moi chuyen view
        if (viewMenu.frame.origin.x<0){
        }else{
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.x -= self.view.frame.width/2
                self.view.frame.origin.x -= self.view.frame.width/2
            }
        }
        delegate?.allUser(self, email: emailUser)
        //
//        ref.child("ListSong").child("1").updateChildValues([
//            "times": 0
//            ])
//        ref.child("ListSong").child("2").updateChildValues([
//            "times": 0
//            ])
//        ref.child("ListSong").child("3").updateChildValues([
//            "times": 0
//            ])
//        ref.child("ListSong").child("4").updateChildValues([
//            "times": 0
//            ])
//        ref.child("ListSong").child("5").updateChildValues([
//            "times": 0
//            ])
//        ref.child("ListSong").child("6").updateChildValues([
//            "times": 0
//            ])
//        ref.child("ListSong").child("7").updateChildValues([
//            "times": 0
//            ])
//        let tableName = ref.child("ListSong").child("1")
//        let userFireBase : [String: AnyObject] = [
//            "id": "1" as String as AnyObject,
//            "name": "Mama" as String as AnyObject,
//            "link": " Mama" as String as AnyObject,
//            "timeplay": self.returnStringDuration(c: " Mama") as String as AnyObject,
//            "times": 0 as Int as AnyObject,
//            "typeVideo": "local" as String as AnyObject,
//            "categoryVideo": "music" as String as AnyObject,
//            "image": "mama" as String as AnyObject]
//        tableName.setValue(userFireBase)
        ///
//        itemsUserSeen = UserPlayerNew.getVideoByUser(seenCheck: "yes")
//        if ((itemsUserSeen?.count)! != 0){
//            for k:Int in 0...(itemsUserSeen?.count)!-1{
//                if (itemsUserSeen?[k].email == emailUser){
//                    print(itemsUserSeen?[k].video)
//                    print(itemsUserSeen?[k].seen)
//                }
//            }
//        }
//        itemsUserLike = UserPlayerNew.getVideoByLikeUser(likeCheck: "yes")
//        if ((itemsUserLike?.count)! != 0){
//            for k:Int in 0...(itemsUserLike?.count)!-1{
//                if (itemsUserLike?[k].email == emailUser){
//                    print(itemsUserLike?[k].video)
//                    print(itemsUserLike?[k].seen)
//                }
//            }
//        }
        
    }
    
    //
    func setUpView(){// 45 la do dai cua cai hien thong bao
        viewMenu = UIView(frame: CGRect(x: -view.frame.width/2, y: 20+(navigationController?.navigationBar.frame.height)!, width: view.frame.width/2, height: view.frame.height-(20+(navigationController?.navigationBar.frame.height)!)))
        navigationController!.view.addSubview(viewMenu)
        viewMenu.backgroundColor = UIColor.blue
    }
    
    func setupTbalview(){
        tblView123 = UITableView(frame: CGRect(x: 0, y: 0, width: viewMenu.frame.width, height: viewMenu.frame.height))
        viewMenu.addSubview(tblView123)
        tblView123.delegate = self
        tblView123.dataSource = self
        tblView123.register(CellTableView.self, forCellReuseIdentifier: "cell")
    }
    
    func Switch(){
        let right = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.right) )
        right.direction = .right
        view.addGestureRecognizer(right)
        let left = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.left) )
        left.direction = .left
        view.addGestureRecognizer(left)
    }
    
    @objc func right(){
        if (viewMenu.frame.origin.x<0){
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.x += self.view.frame.width/2
                self.view.frame.origin.x += self.view.frame.width/2
            }
        }
    }
    @objc func left(){
        if (viewMenu.frame.origin.x<0){
        }else{
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.x -= self.view.frame.width/2
                self.view.frame.origin.x -= self.view.frame.width/2
            }
        }
    }
    //
    @IBOutlet weak var btnAllVideo: UIButton!
    @IBOutlet weak var btnSeenVideo: UIButton!
    @IBOutlet weak var btnLikeVideo: UIButton!
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var viewActivity: UIView!
    @IBOutlet weak var activityy: UIActivityIndicatorView!
    var arrayVideoLike:[VideoItem] = []
    var arrayVideoSeen:[VideoItem] = []
    var arrayVideoFirst:[VideoItem] = []
    
    func ButtonViewVideo(index: Int) {
        if (viewMenu.frame.origin.x<0){
        }else{
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.x -= self.view.frame.width/2
                self.view.frame.origin.x -= self.view.frame.width/2
            }
        }
        indexArray = index
        arrayVideo = arrayVideoFirst
        itemsUser = UserPlayerNew.getVideoByEmail(seenCheck: emailUser)
        if ((itemsUser?.count)! == 0){
            UserPlayerNew(name: emailUser, link: "", seen: "\(index)" , like: "no", timecontinues: 0.0,seen1 : "yes").SaveToUser()
        }else{
            var check : Bool = true
            for k : Int in 0...(itemsUser?.count)!-1{
                if (itemsUser?[k].video == "\(index)" ){
                    itemsUser?[k].UpdateSeen(s: "yes")
                    check = false
                }
            }
            if (check){
                UserPlayerNew(name: emailUser, link: "", seen: "\(index)" , like: "no", timecontinues: 0.0,seen1 : "yes").SaveToUser()
            }
        }
        countSeen = 0
        itemsUserSeen = UserPlayerNew.getVideoByUser(seenCheck: "yes")
        if ((itemsUserSeen?.count)! != 0){
            for k:Int in 0...(itemsUserSeen?.count)!-1{
                if (itemsUserSeen?[k].email == emailUser){
                    countSeen = countSeen + 1
                }
            }
        }
        ref.child("UserList").child(idOfUser).updateChildValues([
            "videoSeen": countSeen
        ])
    }
    
    func ButtonLikeVideo(index: Int) {
        itemsUser = UserPlayerNew.getVideoByEmail(seenCheck: emailUser)
        var check : Bool = true
        if ((itemsUser?.count)! == 0){
            UserPlayerNew(name: emailUser, link: "", seen: "\(index)" , like: "yes", timecontinues: 0.0,seen1 : "no").SaveToUser()
        }else{
            for k : Int in 0...(itemsUser?.count)!-1{
                if ( itemsUser?[k].email == emailUser && itemsUser?[k].video == "\(index)" ){
                    if (itemsUser?[k].likeVideo != "yes"){
                        itemsUser?[k].UpdateLike(YN: "yes")
                    }else{
                        itemsUser?[k].UpdateLike(YN: "no")
                    }
                    check = false
                }
            }
            if (check){
                UserPlayerNew(name: emailUser, link: "", seen: "\(index)" , like: "yes", timecontinues: 0.0,seen1 : "no").SaveToUser()
            }
        }
        // Update Like Video
        countLike = 0
        itemsUserLike = UserPlayerNew.getVideoByLikeUser(likeCheck: "yes")
        if ((itemsUserLike?.count)! != 0){
            for k:Int in 0...(itemsUserLike?.count)!-1{
                if (itemsUserLike?[k].email == emailUser){
                    countLike = countLike + 1
                }
            }
        }
        ref.child("UserList").child(idOfUser).updateChildValues([
                "videoLike": countLike
            ])
        //
        arrayVideo = arrayVideoFirst // phai dua ve lai ban dau
        if (arrayVideo.count == 0){
            if (arrayVideo[0].idVideo! == "\(index)"){
                if (arrayVideo[0].likeVideo == "no"){
                    arrayVideo[0].likeVideo = "yes"
                    if (checkStatusButton == "1"){
                        
                    }else if (checkStatusButton == "2"){
                        arrayVideo = arrayVideo.filter { ($0.seenVideo?.contains("yes"))! }
                    }else{
                        arrayVideo = arrayVideo.filter { ($0.likeVideo?.contains("yes"))! }
                    }
                    tbl.reloadData()
                    return
                }else{
                    if (checkStatusButton == "1"){
                        
                    }else if (checkStatusButton == "2"){
                        arrayVideo = arrayVideo.filter { ($0.seenVideo?.contains("yes"))! }
                    }else{
                        arrayVideo = arrayVideo.filter { ($0.likeVideo?.contains("yes"))! }
                    }
                    arrayVideo[0].likeVideo = "no"
                    tbl.reloadData()
                    return
                }
            }
        }else{
            for k : Int in 0...arrayVideo.count-1{
                if (arrayVideo[k].idVideo! == "\(index)" ){
                    if (arrayVideo[k].likeVideo == "no"){
                        arrayVideo[k].likeVideo = "yes"
                        if (checkStatusButton == "1"){
                            
                        }else if (checkStatusButton == "2"){
                            arrayVideo = arrayVideo.filter { ($0.seenVideo?.contains("yes"))! }
                        }else{
                            arrayVideo = arrayVideo.filter { ($0.likeVideo?.contains("yes"))! }
                        }
                        tbl.reloadData()
                        return
                    }else{
                        arrayVideo[k].likeVideo = "no"
                        if (checkStatusButton == "1"){
                            
                        }else if (checkStatusButton == "2"){
                            arrayVideo = arrayVideo.filter { ($0.seenVideo?.contains("yes"))! }
                        }else{
                            arrayVideo = arrayVideo.filter { ($0.likeVideo?.contains("yes"))! }
                        }
                        tbl.reloadData()
                        return
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designButton()
        // Neu da co ViewMenu thi xoa di va tao cai moi
        self.viewMenu.removeFromSuperview()
        ///
        activityy.startAnimating()
        ref.child("ListSong").observe(DataEventType.value, with: { (snapshot) in
            arrayVideo.removeAll()
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let userDict = userSnap.value as! [String:AnyObject] //child data
                let id = userDict["id"] as? String ?? "No Data"
                let name = userDict["name"] as? String ?? "No Data"
                let link = userDict["link"] as? String ?? "No Data"
                let timeplay = userDict["timeplay"] as? String ?? "No Data"
                let times = userDict["times"] as? Int ?? 0
                let image = userDict["image"] as? String ?? "No Data"
                let typeVideo = userDict["typeVideo"] as? String ?? "No Data"
                let categoryVideo = userDict["categoryVideo"] as? String ?? "No Data"
                arrayVideo.append(VideoItem(id: id, name: name, link: link, seen: "no", like: "no", image : image , times: times, timeplay: timeplay, timecontinues : 0.0,typeVideo : typeVideo ,categoryVideo : categoryVideo ))
            }
            self.arrayVideoFirst = arrayVideo
            self.closeActivity()
            self.reloadData()
            self.tbl.reloadData()
        })
        ref.child("UserList").child(self.idUserToGetCell1).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            self.arrayMenuInfo.removeAll()
            let value = snapshot.value as? [String : AnyObject]
            let name = value?["name"] as? String ?? "No Data"
            self.nameOfUserCell = name
            let imagelink = value?["linkImageFace"] as? String ?? "No Data"
            self.arrayMenuInfo.append(imagelink)
            let fullName = value?["fullName"] as? String ?? "No Data"
            self.arrayMenuInfo.append(fullName)
            let age = value?["age"] as? String ?? "No Data"
            self.arrayMenuInfo.append(age)
            let phone = value?["phone"] as? String ?? "No Data"
            self.arrayMenuInfo.append(phone)
            
            self.setUpView()
            self.setupTbalview()
            self.Switch()
            self.tblView123.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func designButton(){
        btnAllVideo.backgroundColor =  UIColor.blue
        btnSeenVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        btnLikeVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        btnAllVideo.layer.cornerRadius = 15
        btnSeenVideo.layer.cornerRadius = 15
        btnLikeVideo.layer.cornerRadius = 15
    }
    
    func returnStringDuration(c : String) -> String{
       guard let path = Bundle.main.path(forResource: "\(c)", ofType:"mp4") else {
          debugPrint("\(c).mp4 not found")
          return "Null"
       }
       let player = AVPlayer(url: URL(fileURLWithPath:path))
       let duration = CMTimeGetSeconds(player.currentItem!.asset.duration)
       return self.stringFromTime(interval: duration)
    }
    
    func returnStringDurationOnline(c : String) -> String{
        guard let path = URL(string: "\(c)") else {
            debugPrint("\(c).mp4 not found")
            return "Null"
        }
        let player = AVPlayer(url: path)
        let duration = CMTimeGetSeconds(player.currentItem!.asset.duration)
        return self.stringFromTime(interval: duration)
    }
    
    private func stringFromTime(interval : TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewVideo" {
            let controller = segue.destination as! ViewVideo
            controller.indexArray = indexArray
            controller.emailUser = emailUser
            controller.delegate = self
        }
    }
    
    @IBAction func TakeAll(_ sender: Any) {
        btnAllVideo.backgroundColor =  UIColor.blue
        btnSeenVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        btnLikeVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        checkStatusButton = "1"
        arrayVideo = arrayVideoFirst
        tbl.reloadData()
    }

    @IBAction func TakeSeen(_ sender: Any) {
        btnSeenVideo.backgroundColor =  UIColor.blue
        btnAllVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        btnLikeVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        checkStatusButton = "2"
        arrayVideo = arrayVideoFirst
        arrayVideo = arrayVideo.filter { ($0.seenVideo?.contains("yes"))! }
        tbl.reloadData()
    }
    
    
    @IBAction func TakeLike(_ sender: Any) {
        btnLikeVideo.backgroundColor =  UIColor.blue
        btnAllVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        btnSeenVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        checkStatusButton = "3"
        arrayVideo = arrayVideoFirst
        arrayVideo = arrayVideo.filter { ($0.likeVideo?.contains("yes"))! }
        tbl.reloadData()
    }
}

extension ViewController: UISearchBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
//            checkStatusButton = "1"
            
//            items = EntitiesVideoNewUpdate.getVideoBySearch(name: searchBar.text!)
            btnAllVideo.backgroundColor =  UIColor.blue
            btnSeenVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
            btnLikeVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
            arrayVideo = arrayVideoFirst
            arrayVideo = arrayVideo.filter { ($0.nameVideo?.contains(searchBar.text!))! }
            if (arrayVideo.count == 0){
                self.showAlert(message: "No Empty")
            }
            else{
                self.showAlert(message: "Have \(arrayVideo.count) Empty")
            }
            searchBar.text = ""
            tbl.reloadData()
        }else{
            btnAllVideo.backgroundColor =  UIColor.blue
            btnSeenVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
            btnLikeVideo.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
            arrayVideo = arrayVideoFirst
            self.showAlert(message: "Have \(arrayVideo.count) Empty")
            searchBar.text = ""
            tbl.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView  == tblView123
        {
            // place your code here
            return arrayMenu.count
        }else{
            return arrayVideo.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView  == tblView123
        {
            if(indexPath.row == 0){
                let cell = Bundle.main.loadNibNamed("TableViewCell1", owner: self, options: nil)?.first as! TableViewCell1
                let url = URL(string: arrayMenuInfo[0])
                cell.loadImage()
                cell.imageCell1.loadImage(link: url!)
                cell.labelCell1.text = nameOfUserCell
                return cell
            }else{
                let cell = Bundle.main.loadNibNamed("TableViewCell2", owner: self, options: nil)?.first as! TableViewCell2
                cell.labelNameCell2.text = arrayMenu[indexPath.row]
                cell.labelInfoCell2.text = arrayMenuInfo[indexPath.row]
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellTable
            cell.delegate = self // QUAN TRONG
            cell.loadView()
            
            cell.LabelTimes.text = String(arrayVideo[indexPath.row].timesVideo!)
            cell.ImageCell.image = #imageLiteral(resourceName: String(arrayVideo[indexPath.row].imageVideo!) )
            cell.LabelView.text = String( arrayVideo[indexPath.row].timesPlayer!)
            cell.TitleVideo.text = arrayVideo[indexPath.row].nameVideo
            cell.indexArray = Int(arrayVideo[indexPath.row].idVideo!)!
            if (arrayVideo[indexPath.row].likeVideo == "no"){
                cell.LikeVideo.backgroundColor = UIColor.blue
            }else{
                cell.LikeVideo.backgroundColor = UIColor(red: 255.0/255.0, green: 153.0/255.0, blue: 194.0/255.0, alpha: 1)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView  == tblView123
        {
            if(indexPath.row == 0){
                return 130.5
            }else{
                return 80
            }
        }else{
            return 160 // do dai mac dinh cua cell table view to
        }
    }
    
    func reloadData(){
        itemsUserOld = UserPlayerNew.getVideoByEmail(seenCheck: emailUser)
        if ((itemsUserOld?.count)! != 0){
            for k:Int in 0...(itemsUserOld?.count)!-1{
                if (itemsUserOld?[k].email == emailUser){
                    for k1:Int in 0...(arrayVideo.count)-1{
                        if (itemsUserOld?[k].video == (arrayVideo[k1].idVideo)!){
                            arrayVideo[k1].timesContinues = itemsUserOld?[k].timesContinues
                        }
                    }
                }
            }
        }
        itemsUserLike = UserPlayerNew.getVideoByLikeUser(likeCheck: "yes")
        if ((itemsUserLike?.count)! != 0){
            for k:Int in 0...(itemsUserLike?.count)!-1{
                if (itemsUserLike?[k].email == emailUser){
                    for k1:Int in 0...(arrayVideo.count)-1{
                        if (itemsUserLike?[k].video == (arrayVideo[k1].idVideo)!){
                            arrayVideo[k1].likeVideo =  "yes"
                        }
                    }
                }
            }
        }
        itemsUserSeen = UserPlayerNew.getVideoByUser(seenCheck: "yes")
        if ((itemsUserSeen?.count)! != 0){
            for k:Int in 0...(itemsUserSeen?.count)!-1{
                if (itemsUserSeen?[k].email == emailUser){
                    for k1:Int in 0...(arrayVideo.count)-1{
                        if (itemsUserSeen?[k].video == (arrayVideo[k1].idVideo)!){
                            arrayVideo[k1].seenVideo = "yes"
                        }
                    }
                }
            }
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

class CellTableView : UITableViewCell{
    
}


// Add Data
//        EntitiesVideoNewUpdate(id: "1", name: "Mama", link: " Mama", seen: "no", like: "no", image: "mama", times: 0, timeplay: self.returnStringDuration(c: " Mama"),timecontinues : 0.0,typeVideo : "local",categoryVideo : "music").SaveToDataVideo()
//        EntitiesVideoNewUpdate(id: "2", name: "Paris", link: " Paris ", seen: "no", like: "no", image: "paris", times: 0, timeplay:self.returnStringDuration(c: " Paris "),timecontinues : 0.0 ,typeVideo : "local",categoryVideo : "music").SaveToDataVideo()
//        EntitiesVideoNewUpdate(id: "3", name: "All We Know", link: "All We Know", seen: "no", like: "no", image: "sickboy", times: 0, timeplay: self.returnStringDuration(c: "All We Know"),timecontinues : 0.0,typeVideo : "local",categoryVideo : "music").SaveToDataVideo()
//        EntitiesVideoNewUpdate(id: "4", name: "Sick Boy", link: "Sick Boy", seen: "no", like: "no", image: "allweknow", times: 0, timeplay: self.returnStringDuration(c: "Sick Boy"),timecontinues: 0.0,typeVideo : "local",categoryVideo : "music" ).SaveToDataVideo()
//        EntitiesVideoNewUpdate(id: "5", name: "Something Just Like This", link: "Something Just Like This ", seen: "no", like: "no", image: "somethingjust", times: 0, timeplay: self.returnStringDuration(c: "Something Just Like This "),timecontinues: 0.0,typeVideo : "local",categoryVideo : "music" ).SaveToDataVideo()
//        EntitiesVideoNewUpdate(id: "6", name: "We Don't Talk Anymore", link: "We Don't Talk Anymore", seen: "no", like: "no", image: "wedont", times: 0, timeplay: self.returnStringDuration(c: "We Don't Talk Anymore"), timecontinues : 0.0,typeVideo : "local",categoryVideo : "music" ).SaveToDataVideo()
//        print(self.returnStringDurationOnline(c: "http://movietrailers.apple.com/movies/pixar/incredibles-2/incredibles-2-trailer-2_h480p.mov"))
//        EntitiesVideoNewUpdate(id: "7", name: "Incredibles 2", link: "http://movietrailers.apple.com/movies/pixar/incredibles-2/incredibles-2-trailer-2_h480p.mov", seen: "no", like: "no", image: "i2", times: 0, timeplay: self.returnStringDurationOnline(c: "http://movietrailers.apple.com/movies/pixar/incredibles-2/incredibles-2-trailer-2_h480p.mov"), timecontinues : 0.0,typeVideo : "online",categoryVideo : "movie" ).SaveToDataVideo()


//// di voi nhau
//
//extension IndexPath {
//    static func fromRow(_ row: Int) -> IndexPath {
//        return IndexPath(row: row, section: 0)
//    }
//}
//
//extension UITableView {
//    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
//        beginUpdates()
//        deleteRows(at: deletions.map(IndexPath.fromRow), with: .automatic)
//        insertRows(at: insertions.map(IndexPath.fromRow), with: .automatic)
//        reloadRows(at: updates.map(IndexPath.fromRow), with: .automatic)
//        endUpdates()
//    }
//}
//


//        items = EntitiesVideoNewUpdate.getAllVideo()
//        for k:Int in 0...(items?.count)!-1{
//            items?[k].UpdateSeenAgain()
//            items?[k].UpdateLike(YN: "no")
//            items?[k].UpdateTimeContimues(YN: 0.0)
//        }

//        itemsUserOld = UserPlayerNew.getVideoByEmail(seenCheck: emailUser)
//        if ((itemsUserOld?.count)! != 0){
//            for k:Int in 0...(itemsUserOld?.count)!-1{
//                if (itemsUserOld?[k].email == emailUser){
//                    for k1:Int in 0...(items?.count)!-1{
//                        if (itemsUserOld?[k].video == (items?[k1].idVideo)!){
//                            items?[k1].UpdateTimeContimues(YN: (itemsUserOld?[k].timesContinues)!)
//                        }
//                    }
//                }
//            }
//        }

//        itemsUserLike = UserPlayerNew.getVideoByLikeUser(likeCheck: "yes")
//        if ((itemsUserLike?.count)! != 0){
//            for k:Int in 0...(itemsUserLike?.count)!-1{
//                if (itemsUserLike?[k].email == emailUser){
//                    for k1:Int in 0...(items?.count)!-1{
//                        if (itemsUserLike?[k].video == (items?[k1].idVideo)!){
//                            items?[k1].UpdateLike(YN: "yes")
//                        }
//                    }
//                }
//            }
//        }
//
//        itemsUserSeen = UserPlayerNew.getVideoByUser(seenCheck: "yes")
//        if ((itemsUserSeen?.count)! != 0){
//            for k:Int in 0...(itemsUserSeen?.count)!-1{
//                if (itemsUserSeen?[k].email == emailUser){
//                    for k1:Int in 0...(items?.count)!-1{
//                        if (itemsUserSeen?[k].video == (items?[k1].idVideo)!){
//                            items?[k1].UpdateSeen()
//                        }
//                    }
//                }
//            }
//        }

