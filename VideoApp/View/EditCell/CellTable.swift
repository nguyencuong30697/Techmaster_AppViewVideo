//
//  CellTable.swift
//  VideoApp
//
//  Created by NM Cường on 23/06/2018.
//  Copyright © 2018 NM Cường. All rights reserved.
//

import UIKit

protocol CellDelagate: class{
    func ButtonViewVideo(index : Int)
    func ButtonLikeVideo(index : Int)
}

class CellTable: UITableViewCell {

    weak var delegate : CellDelagate?
    
    var indexArray : Int = 0
    @IBOutlet weak var ViewCell: UIView!
    @IBOutlet weak var ImageCell: UIImageView!
    @IBOutlet weak var TitleVideo: UILabel!
    @IBOutlet weak var LabelView: UILabel!
    @IBOutlet weak var LabelTimes: UILabel!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var LikeVideo: UIButton!
    
    @IBAction func ViewVideo(_ sender: Any) {
        delegate?.ButtonViewVideo(index: indexArray)
    }
    
    @IBAction func LikeVideo(_ sender: Any) {
        delegate?.ButtonLikeVideo(index: indexArray)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func loadView(){
        ViewCell.backgroundColor = UIColor(red: 222/255.0, green: 254/255.0, blue: 50/255.0, alpha: 1.0)
        ViewCell.layer.cornerRadius = 10
        btnView.layer.cornerRadius = 15
        LikeVideo.layer.cornerRadius = 15
    }

}
