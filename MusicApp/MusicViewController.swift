//
//  MusicViewController.swift
//  MusicApp
//
//  Created by 坪川和生 on 2021/11/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class MusicViewController: UIViewController {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UIButton!
    @IBOutlet weak var songFileName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSongInfoFromLaravelSongApp()
    }
    
    
    
    @IBAction func artistNameButton(_ sender: Any) {
    }
    
    @IBAction func likeButton(_ sender: Any) {
    }
    
    @IBAction func nextSongButton(_ sender: Any) {
    }
    
    func getSongInfoFromLaravelSongApp() {
        //リクエストのURLの生成
        let url = URL(string: "http://localhost/api/songs/1")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"]
        //Alamofireでリクエストする
        AF.request(url, method: .get, encoding: JSONEncoding.default,headers: headers).responseJSON { response in
            switch response.result {
                //successの時
            case .success(let value):
                //SwiftyJSONでDecode
                let json = JSON(value)
                print(json)
                //レスポンスで受け取った値から、Song型のオブジェクトを作成
                let song = Song(
                    image: json["image"].string!,
                    title: json["title"].string!,
                    artistname: json["artist"]["name"].string!,
                    file_name: json["file_name"].string!)
                //プロフィール画面にSong型のオブジェクトの中身を反映
                self.setSong(song: song)
                //failureの時
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    //Song型オブジェクトに含まれる値を、それぞれ、LabelやImageViewに表示させるメソッド
    func setSong(song: Song) {
        //プロフィール画像のURLを生成
        let image = URL(string: song.image)!
        //KingfisherでURLの画像を取得してImageViewのImageに表示   //俺はここがFirebaseになる？
        songImage.kf.setImage(with: image)
        //それぞれのLabelに表示
        songNameLabel.text = song.title
        artistNameLabel.titleLabel?.text = song.artistname
        songFileName.text = song.file_name
        

    }
    
    
    
}
