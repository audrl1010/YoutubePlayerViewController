//
//  PlayerControl.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit

protocol PlayerControlDelegate: class {
  func playerControl(_ playerControl: PlayerControl, didTouchPlayButton state: PlayButtonState)
}

enum PlayButtonState: String {
  case pause
  case play
}

class PlayerControl: BaseView {
  
  // MARK: - Properties
  
  weak var delegate: PlayerControlDelegate?
  
  let popUpImageViewWidth = CGFloat(160)
  let popUpImageViewHeight = CGFloat(90)
  
  // MARK: - UI
  
  var gradientLayer = CAGradientLayer().then {
    $0.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    $0.locations = [0.7, 1.2]
  }
  
  var currentTimeLabel = UILabel().then {
    $0.text = "00:00"
    $0.textColor = .white
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textAlignment = .left
  }
  
  var durationLabel = UILabel().then {
    $0.text = "00:00"
    $0.textColor = .white
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textAlignment = .right
  }
  
  var progress = Slider().then {
    $0.minimumTrackView.backgroundColor = .red
    $0.availableTrackView.backgroundColor = .lightGray
    $0.maximumTrackView.backgroundColor = .white
    $0.thumbView.backgroundColor = .red
  }
  
  var popUpImageView = PopUpImageView().then {
    $0.backgroundColor = .black
    $0.alpha = 0.0
  }
  
  var playButton = UIButton().then {
    $0.setImage(#imageLiteral(resourceName: "play"), for: .normal)
  }
  
  var isPlaying = false {
    didSet {
      playButton.setImage(isPlaying ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play"), for: .normal)
    }
  }
  
  var popUpImageViewLeftConstraint: NSLayoutConstraint?
  
  // MARK: - Action
  
  @objc func playButtonDidTouch() {
    isPlaying = !isPlaying
    delegate?.playerControl(self, didTouchPlayButton: isPlaying ? .play : .pause)
  }
  
  // MARK: - Layout
  override func setupViews() -> [CanBeSubview]? {
    playButton.addTarget(self, action: #selector(playButtonDidTouch), for: .touchUpInside)
    
    return [
      gradientLayer,
      currentTimeLabel,
      durationLabel,
      progress,
      playButton,
      popUpImageView
    ]
  }
  
  override func updateLayout() {
    gradientLayer.frame = frame
  }
  
  override func setupConstraints() {
    currentTimeLabel.flu
      .leftAnchor(equalTo: leftAnchor, constant: 16)
      .bottomAnchor(equalTo: bottomAnchor, constant: -30)
      .widthAnchor(equalToConstant: 60)
      .heightAnchor(equalToConstant: 24)
    
    durationLabel.flu
      .rightAnchor(equalTo: rightAnchor, constant: -16)
      .bottomAnchor(equalTo: bottomAnchor, constant: -30)
      .widthAnchor(equalToConstant: 60)
      .heightAnchor(equalToConstant: 24)
    
    progress.flu
      .leftAnchor(equalTo: currentTimeLabel.rightAnchor)
      .rightAnchor(equalTo: durationLabel.leftAnchor)
      .bottomAnchor(equalTo: bottomAnchor, constant: -33)
    
    playButton.flu
      .centerXAnchor(equalTo: centerXAnchor)
      .centerYAnchor(equalTo: centerYAnchor)
      .widthAnchor(equalToConstant: 50)
      .heightAnchor(equalToConstant: 50)
    
    popUpImageView.flu
      .leftAnchor(equalTo: leftAnchor, constraint: &popUpImageViewLeftConstraint)
      .widthAnchor(equalToConstant:  popUpImageViewWidth)
      .heightAnchor(equalToConstant: popUpImageViewHeight)
      .bottomAnchor(equalTo: progress.topAnchor, constant: -10)
  }
}

