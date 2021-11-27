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
import Firebase
import AVFoundation


class MusicViewController: UIViewController {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UIButton!
    
    @IBOutlet weak var scrubLabel: UILabel!
    @IBOutlet weak var scrubSlider: UISlider!
    //スライダーと曲を連動させるタイマー
    var timer = Timer()
    //プレイヤーの現在地
    var currentTime = 0.0
    var playorpause = 0
    
//    var musicPath = Bundle.main.bundleURL.appendingPathComponent("")
    
    var songImageFileName:String!
    var artistImageFileName:String!
    var songFileName:String!
    var player = AVAudioPlayer()
    var songs_count:Int = 30
    var artist:Artist!
    var artistImage:UIImage!
    let consts = Constants.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrubSlider.value = 0.0  // 初期値を0.0に設定
        scrubSlider.maximumValue = 1.0  // 最大値を1.0に設定
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSongInfoFromLaravelSongApp()
    }
    
    @IBAction func artistNameButton(_ sender: Any) {
        let artistVC = self.storyboard?.instantiateViewController(withIdentifier: "artistVC") as! ArtistViewController
        artistVC.artist = self.artist
        artistVC.artistImageFile = self.artistImage
        self.present(artistVC, animated: true, completion: nil)
    }
    
    func getSongInfoFromLaravelSongApp() {
        //キーチェーンからアクセストークンを取り出す
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token") }
        //リクエストのURLの生成
        let song_id = String(Int.random(in: 1...songs_count))
        let url = URL(string: "http://localhost/api/songs/\(song_id)")!
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json",
            "Authorization": "Bearer \(accessToken)"
        ]
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
                
                self.artist = Artist(
                    image: json["artist"]["image"].string!,
                    artistname: json["artist"]["name"].string!,
                    prefecture: json["artist"]["prefecture"]["name"].string!,
                    introduction: json["artist"]["introduction"].string)
                
                self.songs_count = json["songs_count"].int!
                //Music画面にSong型のオブジェクトの中身を反映
                self.songImageFileName = song.image
                self.artistImageFileName = self.artist.image
                self.songFileName = song.file_name
                self.changeLabel(song: song)
                self.setSongImage()
                self.setArtistImageFile()
                self.setSongFile()
                
                DispatchQueue.main.async {
                    self.player.currentTime = TimeInterval(self.scrubSlider.value)

                    self.scrubSlider.maximumValue = Float(self.player.duration)
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
                }
                //failureの時
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    //Song型オブジェクトに含まれる値を、それぞれ、LabelやImageViewに表示させるメソッド
    func changeLabel(song: Song) {
        //それぞれのLabelに表示
        songNameLabel.text = song.title
        //        artistNameLabel.titleLabel?.text = song.artistname  //これだったらアーティストが入ってくるになる
        artistNameLabel.setTitle(song.artistname, for: .normal )
        print(artistNameLabel.titleLabel?.text)
    }
    
    func setSongImage(){
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let islandRef = storageRef.child("song_image/\(self.songImageFileName!)")
        
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.songImage.image = image
            }
        }
    }
    
    func setArtistImageFile(){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let islandRef = storageRef.child("artist_image/\(self.artistImageFileName!)")
        print(islandRef)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.artistImage = image
            }
        }
    }
    
    func setSongFile() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let songsRef = storageRef.child("song_file/\(self.songFileName!)")
        
        // Fetch the download URL
        songsRef.downloadURL { url, error in
            if let error = error {
                // Handle any errors
            } else {
                let urlstring = url!.absoluteString
                let url = NSURL(string: urlstring)
                print("the url = \(url!)")
                self.downloadSongFileFromURL(url: url! as URL)
            }
        }
    }

    func downloadSongFileFromURL(url:URL){
        var downloadTask:URLSessionDownloadTask = URLSession.shared.downloadTask(with: url as URL) { (URL, response, error) in
            self.play(url: URL!)
        }
        downloadTask.resume()
    }
    
    func play(url:URL) {   //上でダウンロードした状態のものを再生している
        print("playing \(url)")

        do {
            self.player = try AVAudioPlayer(contentsOf: url as URL)
            player.prepareToPlay()
            player.volume = 1.0
            
//            player.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    @IBAction func playButton(_ sender: Any) {
        switch playorpause {
//        case -1:
//            createplayer()
//            playorpause = 1
        case 0:
            playplayer()
            playorpause = 1
        case 1:
            pauseplayer()
            playorpause = 0
        default:
            break
        }
        
    }
    
    @IBAction func stopButton(sender: AnyObject) {
        
        player.stop()
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        getSongInfoFromLaravelSongApp()
    }
    
    @IBAction func scrubSilder(_ sender: Any) {
        player.currentTime = TimeInterval(scrubSlider.value)
        
        scrubSlider.maximumValue = Float(player.duration)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    //スライダーの現在位置を曲の再生位置に指定
    @objc func updateTime() {
        UIView.animate(withDuration: 1.0, animations: {
            self.scrubSlider.setValue(Float(self.player.currentTime), animated: true)
        })
    }
    
    //プレイヤーを作成する
//    func createplayer() {
//        do {
//            player = try AVAudioPlayer(contentsOf: musicPath, fileTypeHint: nil)
//            //スライダーの長さを音楽長さに同期する
//            scrubSlider.maximumValue = Float(player.duration)
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
//            player.play()
//        } catch {
//            print("エラーが起きました")
//        }
//    }
    
    //プレイヤーを再生する
    func playplayer() {
        player.play()
        player.currentTime = currentTime
        if timer.isValid == false {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }
    
    //プレイヤーを停止する
    func pauseplayer() {
        player.pause()
        currentTime = player.currentTime
        timer.invalidate()
    }
    
    
}
