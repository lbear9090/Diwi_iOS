//
//  LookHeaderCollectionViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/16/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import GPVideoPlayer
class LookHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!
    var playercontroller = AVPlayerViewController()
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImage.contentMode = .scaleAspectFill
    }
    
//    func playVideo(videoUrl: String){
//
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .black
//        view.frame = contentView.bounds
//        contentView.addSubview(view)
//        backgroundImage.isHidden = true
//        let videoURL = URL(string: videoUrl)
//        player = AVPlayer(url: videoURL!)
////        self.showsPla
////        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
////        self.addTimeObserver()
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = contentView.bounds
//
//        view.layer.addSublayer(playerLayer)
//        player.play()
//
//    }
//
//    func playVideo(videoUrl: String){
//        let videoURL = URL(string: videoUrl)
//        player = AVPlayer(url: videoURL!)
//        player.rate = 1 //auto play
//        let playerFrame = CGRect(x: 0, y: contentView.frame.height/9, width: contentView.frame.width, height: contentView.frame.height/1.6)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        playerViewController.view.frame = playerFrame
//
////        addChild(playerViewController)
//        contentView.addSubview(playerViewController.view)
////        playerViewController.didMove(toParent: self)
//        playercontroller.showsPlaybackControls = true
//    }
    
    
    func playVideo(videoUrl: String){
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.frame = contentView.bounds
        contentView.addSubview(view)
        let player = GPVideoPlayer.initialize(with: self.contentView.bounds)!
        self.contentView.addSubview(player)
        let url = URL(string: videoUrl)!
        player.loadVideo(with: url)
        player.isToShowPlaybackControls = true
        player.playVideo()
    }
    
    
//    func addTimeObserver(){
//        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//        let mainQueue = DispatchQueue.main
//        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: {[weak self] time in
//            guard let currentItem = self?.player.currentItem else {return}
//            self?.slider.maximumValue = 20//Float(currentItem.duration.seconds)
//            self?.slider.minimumValue = 0
//            self?.slider.value = Float(currentItem.currentTime().seconds)
//
//
//        })
//
//    }

//    @IBAction func sliderChanged(_ sender: UISlider) {
//        player.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
//    }
    
//    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "duration", let duration = player.currentItem!.duration.seconds, duration > 0.0{
//
//
//
//        }
//    }
}
