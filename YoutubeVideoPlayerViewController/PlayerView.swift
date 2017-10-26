//
//  PlayerView.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit
import AVFoundation

enum PlayerFillMode {
  case resize
  case resizeAspectFill
  case resizeAspectFit // default
}

class PlayerView: BaseView {
  override class var layerClass: Swift.AnyClass {
    return AVPlayerLayer.self
  }
  
  var playerLayer: AVPlayerLayer {
    return layer as! AVPlayerLayer
  }
  
  var player: AVPlayer? {
    get { return playerLayer.player }
    set(new) { playerLayer.player = new }
  }
  
  var fillMode: AVLayerVideoGravity {
    get { return playerLayer.videoGravity }
    set(new) { playerLayer.videoGravity = new }
  }
}


