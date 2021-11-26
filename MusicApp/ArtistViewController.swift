//
//  ArtistViewController.swift
//  MusicApp
//
//  Created by 坪川和生 on 2021/11/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher
import Firebase

class ArtistViewController: UIViewController {
    
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var prefectureLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    var imageFileName:String!
    var artist:Artist!
    var artistImageFile:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistImage.image = artistImageFile
        artistNameLabel.text = artist.artistname
        prefectureLabel.text = artist.prefecture
        
        if artist.introduction != nil {
        introductionLabel.text = artist.introduction!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        getArtistInfoFromLaravelSongApp()
    }
    
//    func getArtistInfoFromLaravelSongApp() {
//        //リクエストのURLの生成
//        let url = URL(string: "http://localhost/api/artists/8")!
//        let headers: HTTPHeaders = [
//            "Content-Type": "application/json",
//            "ACCEPT": "application/json"]
//        //Alamofireでリクエストする
//        AF.request(url, method: .get, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
//            switch response.result {
//                //successの時
//            case .success(let value):
//                //SwiftyJSONでDecode
//                let json = JSON(value)
//                print(json)
//
//                //レスポンスで受け取った値から、artist型のオブジェクトを作成
//                let artist = Artist(
//                    image: json["image"].string!,
//                    artistname: json["name"].string!,
//                    prefecture: json["prefecture"]["name"].string!,
//                    introduction: json["introduction"].string!)
//                //Music画面にartist型のオブジェクトの中身を反映
//                self.imageFileName = artist.image
//                self.changeLabel(artist: artist)
//                self.setArtistImageFile()
//                //failureの時
//            case .failure(let err):
//                print(err.localizedDescription)
//            }
//        }
//    }
    
    //それぞれ、LabelやImageViewに表示させるメソッド
    func changeLabel(artist: Artist) {
        //それぞれのLabelに表示
        artistNameLabel.text = artist.artistname
        prefectureLabel.text = artist.prefecture
        introductionLabel.text = artist.introduction
    }
    
    func setArtistImageFile(){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let islandRef = storageRef.child("artist_image/\(self.imageFileName!)")
        
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.artistImage.image = image
            }
        }
    }

}
