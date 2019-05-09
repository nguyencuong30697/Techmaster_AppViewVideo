//
//  ViewVideo.swift
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

protocol VideoDeleGate: class {
    func ListReadLoad(_ controller: ViewVideo)
}

class ViewVideo: UIViewController {
    
    weak var delegate: VideoDeleGate?
    
    @IBAction func cancelButton(_ sender: Any) {
        player?.pause()
        let duration : CMTime = player!.currentItem!.asset.duration
        let newCurrentTime : TimeInterval = Double(sliderTime.value) * CMTimeGetSeconds(duration)
        for k : Int in 0...arrayVideo.count-1{
            if (Int(arrayVideo[k].idVideo!)! == indexArray ){
                arrayVideo[k].timesContinues =  newCurrentTime
            }
        }
        for k : Int in 0...itemsUser!.count-1{
            if (Int(itemsUser![k].video) == indexArray ){
                itemsUser![k].UpdateTimeContimues(YN: newCurrentTime)
            }
        }
        if (viewMenu.frame.origin.y == (20+(self.navigationController?.navigationBar.frame.height)!))
        { // Xet xem no co hien len tren man hinh ko
            UIView.animate(withDuration: 0.5) {
                self.viewMenu.frame.origin.y = self.view.frame.height
            }
        }
        delegate?.ListReadLoad(self)
    }
    
    @IBAction func cancelButton2(_ sender: Any) {
        if (viewMenu.frame.origin.y == (20+(self.navigationController?.navigationBar.frame.height)!))
        { // Xet xem no co hien len tren man hinh ko
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.y = self.view.frame.height
            }
        }else{
            UIView.animate(withDuration: 1) {
                self.viewMenu.frame.origin.y = self.viewMenu.frame.origin.y - self.view.frame.height+20+(self.navigationController?.navigationBar.frame.height)!
            }
        }
    }
    
    private var itemsUser: Results<UserPlayerNew>?
    private var itemsUserSeen: Results<UserPlayerNew>?
    var indexArray = Int()
    var emailUser = String()
    @IBOutlet weak var ViewBTN: UIView!
    @IBOutlet weak var timeStart: UILabel!
    @IBOutlet weak var timeOut: UILabel!
    @IBOutlet weak var sliderTime: UISlider!
    @IBOutlet weak var btnNextPhai: UIButton!
    @IBOutlet weak var btnNextTRai: UIButton!
    @IBOutlet weak var btnPlayStop: UIButton!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var ViewTitle: UIView!
    @IBOutlet weak var titleVideo: UILabel!
    var timeOserver : Any?
    var player : AVPlayer?
    var playerlayer : AVPlayerLayer?
    
    @IBAction func hide(_ sender: UITapGestureRecognizer) {
        if ViewBTN.isHidden {
            ViewBTN.isHidden = false
        }else{
            ViewBTN.isHidden = true
        }
        if (self.navigationController?.isNavigationBarHidden)! {
            self.navigationController?.isNavigationBarHidden = false;
        }else{
            self.navigationController?.isNavigationBarHidden = true;
        }
    }
    
    var viewMenu : UIView = UIView()
    
    func setUpView(){// 45 la do dai cua cai hien thong bao
        viewMenu =  UIView(frame: CGRect(x: 0, y: self.view.frame.height , width: view.frame.width, height: view.frame.height-(20+(navigationController?.navigationBar.frame.height)!)))
        navigationController!.view.addSubview(viewMenu)
        viewMenu.backgroundColor = UIColor.blue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewMenu.removeFromSuperview()
        self.setUpView()
        ViewBTN.backgroundColor = UIColor(red: 52.0/255.0 , green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.6)
        itemsUser = UserPlayerNew.getVideoByEmail(seenCheck: emailUser)
        let numeberList : Int =  (arrayVideo.count)
        for k : Int in 0...numeberList-1 {
            if (Int(arrayVideo[k].idVideo!)! == indexArray ){
                let timesView = arrayVideo[k].timesVideo
                arrayVideo[k].timesVideo = timesView! + 1
                ref.child("ListSong").child("\(arrayVideo[k].idVideo!)").updateChildValues([
                    "times": timesView! + 1
                    ])
                arrayVideo[k].seenVideo = "yes"
                self.navigationItem.title =  arrayVideo[k].nameVideo
                if (arrayVideo[k].typeVideo == "online"){
                    guard let path = URL(string: arrayVideo[k].linkVideo! ) else {
                        debugPrint(" not found")
                        return
                    }
                    player = AVPlayer(url: path)
                }else{
                    guard let path = Bundle.main.path(forResource: arrayVideo[k].linkVideo , ofType:"mp4") else {
                        debugPrint("Not found")
                        return
                    }
                    player = AVPlayer(url: URL(fileURLWithPath:path))
                }
                playerlayer = AVPlayerLayer(player: player)
                playerlayer?.frame = self.view.bounds
                self.view.layer.addSublayer(playerlayer!)
                view.bringSubviewToFront(ViewBTN)
                let timeInterval : CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10) // update sau moi mot lan / update tat ca
                timeOserver =  player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { [weak self] (elpsedTime) in
                    self?.observerTime(elpsedTime : elpsedTime )
                })
                let checkContinues = arrayVideo[k].timesContinues
                if (checkContinues == 0){
                    player?.play()
                    btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                }else{
                    let alert = UIAlertController(title: "See Video", message: "Are You Want To Play Video Continues In \(stringFromTime(interval: TimeInterval(checkContinues!))) ?", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                        let seekToTime : CMTime = CMTimeMakeWithSeconds(checkContinues!, preferredTimescale: 600)
                        self.self.player?.seek(to: seekToTime) { (completed : Bool) in
                            self.player?.play()
                        }
                        self.btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                        self.player?.play()
                        self.btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnPlay(_ sender: Any) {
        if player?.rate == 1 {
            guard let player = player else {
                return
            }
            player.pause()
            btnPlayStop.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        }else{
            guard let player = player else {
                return
            }
            player.play()
            btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
        }
    }
    
    @IBAction func nextTrai(_ sender: Any) {
        player?.pause()
        for k : Int in 0...arrayVideo.count-1{
            if (Int(arrayVideo[k].idVideo!)! == indexArray ){
                if (k==0){
                    indexArray = Int(arrayVideo[arrayVideo.count-1].idVideo!)!
                    arrayVideo[arrayVideo.count-1].seenVideo = "yes"
                    var check : Bool = true
                    for k1 : Int in 0...(itemsUser?.count)!-1{
                        if (itemsUser?[k1].video == arrayVideo[arrayVideo.count-1].idVideo! ){
                            itemsUser?[k1].UpdateSeen(s: "yes")
                            check = false
                        }
                    }
                    if (check){
                        UserPlayerNew(name: emailUser, link: "", seen: arrayVideo[arrayVideo.count-1].idVideo! , like: "no", timecontinues: 0.0,seen1 : "yes").SaveToUser()
                    }
                    //
                    UpdateSeenCount()
                    //
                    let timesView = arrayVideo[arrayVideo.count-1].timesVideo
                    arrayVideo[arrayVideo.count-1].timesVideo = timesView! + 1
                    ref.child("ListSong").child("\(arrayVideo[arrayVideo.count-1].idVideo!)").updateChildValues([
                        "times": timesView! + 1
                        ])
                    arrayVideo[arrayVideo.count-1].seenVideo = "yes"
                    self.navigationItem.title =  arrayVideo[arrayVideo.count-1].nameVideo
                    if (arrayVideo[arrayVideo.count-1].typeVideo == "online"){
                        guard let path = URL(string: arrayVideo[arrayVideo.count-1].linkVideo! ) else {
                            debugPrint(" not found")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: path))
                    }else{
                        guard let path = Bundle.main.path(forResource: arrayVideo[arrayVideo.count-1].linkVideo! , ofType:"mp4") else {
                            debugPrint("Not found + \(arrayVideo[arrayVideo.count-1].linkVideo!)")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath:path)))
                    }
                    player?.play()
                    let timeInterval : CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10) // update sau moi mot lan / update tat ca
                    timeOserver =  player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { [weak self] (elpsedTime) in
                        self?.observerTime(elpsedTime : elpsedTime )
                    })
                    btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                    return
                }else{
                    indexArray = Int(arrayVideo[k-1].idVideo!)!
                    arrayVideo[k-1].seenVideo = "yes"
                    var check : Bool = true
                    for k1 : Int in 0...(itemsUser?.count)!-1{
                        if (itemsUser?[k1].video == arrayVideo[k-1].idVideo ){
                            itemsUser?[k1].UpdateSeen(s: "yes")
                            check = false
                        }
                    }
                    if (check){
                        UserPlayerNew(name: emailUser, link: "", seen: arrayVideo[k-1].idVideo! , like: "no", timecontinues: 0.0,seen1 : "yes").SaveToUser()
                    }
                    //
                    UpdateSeenCount()
                    //
                    let timesView = arrayVideo[k-1].timesVideo
                    arrayVideo[k-1].timesVideo = timesView! + 1
                    ref.child("ListSong").child("\(arrayVideo[k-1].idVideo!)").updateChildValues([
                        "times": timesView! + 1
                        ])
                    arrayVideo[k-1].seenVideo = "yes"
                    self.navigationItem.title = arrayVideo[k-1].nameVideo
                    if (arrayVideo[k-1].typeVideo == "online"){
                        guard let path = URL(string: arrayVideo[k-1].linkVideo! ) else {
                            debugPrint(" not found")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: path))
                    }else{
                        guard let path = Bundle.main.path(forResource: arrayVideo[k-1].linkVideo! , ofType:"mp4") else {
                            debugPrint("Not found")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath:path)))
                    }
                    player?.play()
                    let timeInterval : CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10) // update sau moi mot lan / update tat ca
                    timeOserver =  player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { [weak self] (elpsedTime) in
                        self?.observerTime(elpsedTime : elpsedTime )
                    })
                    btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                    return
                }
            }
        }
    }
    
    @IBAction func nextPhai(_ sender: Any) {
        player?.pause()
        for k : Int in 0...arrayVideo.count-1{
            if (Int(arrayVideo[k].idVideo!)! == indexArray ){
                if (k==arrayVideo.count-1){
                    indexArray = Int(arrayVideo[0].idVideo!)!
                    arrayVideo[0].seenVideo = "yes"
                    var check : Bool = true
                    for k1 : Int in 0...(itemsUser?.count)!-1{
                        if (itemsUser?[k1].video == arrayVideo[0].idVideo! ){
                            itemsUser?[0].UpdateSeen(s: "yes")
                            check = false
                        }
                    }
                    if (check){
                        UserPlayerNew(name: emailUser, link: "", seen: arrayVideo[0].idVideo! , like: "no", timecontinues: 0.0,seen1 : "yes").SaveToUser()
                    }
                    //
                    UpdateSeenCount()
                    //
                    let timesView = arrayVideo[0].timesVideo
                    arrayVideo[0].timesVideo = timesView! + 1
                    ref.child("ListSong").child("\(arrayVideo[0].idVideo!)").updateChildValues([
                        "times": timesView! + 1
                        ])
                    arrayVideo[0].seenVideo = "yes"
                    self.navigationItem.title =  arrayVideo[0].nameVideo
                    if (arrayVideo[0].typeVideo == "online"){
                        guard let path = URL(string: arrayVideo[0].linkVideo! ) else {
                            debugPrint(" not found")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: path))
                    }else{
                        guard let path = Bundle.main.path(forResource: arrayVideo[0].linkVideo! , ofType:"mp4") else {
                            debugPrint("Not found")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath:path)))
                    }
                    player?.play()
                    let timeInterval : CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10) // update sau moi mot lan / update tat ca
                    timeOserver =  player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { [weak self] (elpsedTime) in
                        self?.observerTime(elpsedTime : elpsedTime )
                    })
                    btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                    return
                }else{
                    indexArray = Int(arrayVideo[k+1].idVideo!)!
                    arrayVideo[k+1].seenVideo = "yes"
                    var check : Bool = true
                    for k1 : Int in 0...(itemsUser?.count)!-1{
                        if (itemsUser?[k1].video == arrayVideo[k+1].idVideo ){
                            itemsUser?[k1].UpdateSeen(s: "yes")
                            check = false
                        }
                    }
                    if (check){
                        UserPlayerNew(name: emailUser, link: "", seen: arrayVideo[k+1].idVideo! , like: "no", timecontinues: 0.0,seen1 : "yes").SaveToUser()
                    }
                    //
                    UpdateSeenCount()
                    //
                    let timesView = arrayVideo[k+1].timesVideo
                    arrayVideo[k+1].timesVideo = timesView! + 1
                    ref.child("ListSong").child("\(arrayVideo[k+1].idVideo!)").updateChildValues([
                        "times": timesView! + 1
                        ])
                    arrayVideo[k+1].seenVideo = "yes"
                    self.navigationItem.title =  arrayVideo[k+1].nameVideo
                    if (arrayVideo[k+1].typeVideo == "online"){
                        guard let path = URL(string: arrayVideo[k+1].linkVideo! ) else {
                            debugPrint(" not found")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: path))
                    }else{
                        guard let path = Bundle.main.path(forResource: arrayVideo[k+1].linkVideo! , ofType:"mp4") else {
                            debugPrint("Not found")
                            return
                        }
                        player?.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath:path)))
                    }
                    player?.play()
                    let timeInterval : CMTime = CMTimeMakeWithSeconds(1.0, preferredTimescale: 10) // update sau moi mot lan / update tat ca
                    timeOserver =  player?.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { [weak self] (elpsedTime) in
                        self?.observerTime(elpsedTime : elpsedTime )
                    })
                    btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
                    return
                }
            }
        }
    }
    
    func UpdateSeenCount(){
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Hide the navigation bar for current view controller
//        self.navigationController?.isNavigationBarHidden = true;
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // Show the navigation bar on other view controllers
//        self.navigationController?.isNavigationBarHidden = false;
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
        }) { (context) in
            self.view.frame.size = size
            self.view.bringSubviewToFront(self.ViewBTN)
            self.playerlayer?.frame = self.view.bounds
        }
    }
    
    // UI of Slider
    @IBAction func StartVide(_ sender: Any) {
        guard let player = player else {
            return
        }
        let duration : CMTime = player.currentItem!.asset.duration
        let second : Float64 = CMTimeGetSeconds(duration) * Double(sliderTime.value)
        
        timeStart.text = self.stringFromTime(interval: second)
        btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
    }
    
    
    @IBAction func slider1(_ sender: UISlider) {
        guard let player = player else {
            return
        }
        let duration : CMTime = player.currentItem!.asset.duration
        let newCurrentTime : TimeInterval = Double(sender.value) * CMTimeGetSeconds(duration)
        let seekToTime : CMTime = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        player.seek(to: seekToTime) { (completed : Bool) in
            //            if self.playerRateBeforeSeek > 0 {
            player.play()
            //            }
        }
        btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
    }
    
    @IBAction func slider2(_ sender: UISlider) {
        guard let player = player else {
            return
        }
        let duration : CMTime = player.currentItem!.asset.duration
        let newCurrentTime : TimeInterval = Double(sender.value) * CMTimeGetSeconds(duration)
        let seekToTime : CMTime = CMTimeMakeWithSeconds(newCurrentTime, preferredTimescale: 600)
        player.seek(to: seekToTime) { (completed : Bool) in
            //            if self.playerRateBeforeSeek > 0 {
            player.play()
            //            }
        }
        btnPlayStop.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
    }
    
    // cham vao slider la pause lai
    @IBAction func sliderTouchdown(_ sender: Any) {
        guard let player = player else {
            return
        }
        player.pause()
    }
    
    private func observerTime(elpsedTime : CMTime){
        guard let currentPlayer = player else {
            return
        }
        let duration = CMTimeGetSeconds(currentPlayer.currentItem!.asset.duration)
        let elpsedTime = CMTimeGetSeconds(elpsedTime)
        timeOut.text = self.stringFromTime(interval: duration)
        timeStart.text = self.stringFromTime(interval: elpsedTime)
        sliderTime.setValue(Float(elpsedTime/duration), animated: true)
        let playerlayer = AVPlayerLayer(player: player)
        playerlayer.frame = self.view.bounds
    }
    
    private func stringFromTime(interval : TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
    
    deinit {
        if timeOserver != nil{
            player?.removeTimeObserver(self.timeOserver!) // remove time oserver neu khong no se cu chay
        }
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
