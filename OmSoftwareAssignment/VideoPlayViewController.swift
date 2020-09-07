//
//  VideoPlayViewController.swift
//  OmSoftwareAssignment
//
//  Created by Shubham Vinod Kamdi on 05/09/20.
//

import UIKit
import BMPlayer
import SnapKit
import AVKit
class VideoPlayViewController: UIViewController {

    var player:AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let str: String  = Constant.PIC + "product_video15994590312106Q3HEOLI12pdADbRi13376253575f55ced7336ad.mov"
        
        let videoURL = URL(string: str)
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
//        self.addChild(<#T##childController: UIViewController##UIViewController#>)
        self.view.layer.addSublayer(playerLayer)
        player.play()
        // Do any additional setup after loading the view.
    }
    

    
}
