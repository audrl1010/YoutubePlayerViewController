//
//  PlayerViewController.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Delegate

protocol PlayerViewControllerDelegate: class {
  func playerViewControllerDelegateIsReadyForDisplay()
}

class PlayerViewController: BaseViewController {
  
  // MARK: - Properties
  
  var url: URL? = nil {
    didSet {
      if let url = url {
        let playerItem = AVPlayerItem(url: url)
        imageGenerator?.cancelAllCGImageGeneration()
        imageGenerator = AVAssetImageGenerator(asset: playerItem.asset)
        imageGenerator?.appliesPreferredTrackTransform = true
        imageGenerator?.maximumSize = CGSize(
          width: playerControl.popUpImageViewWidth,
          height: playerControl.popUpImageViewHeight
        )
        player.replaceCurrentItem(with: playerItem)
        player.playFromBeginning()
        playerControl.isPlaying = true
        playerControl.alpha = 0
      }
    }
  }
  
  weak var delegate: PlayerViewControllerDelegate?
  
  private(set) var player = Player()
  
  private(set) var playerView = PlayerView()
  
  private(set) var playerControl = PlayerControl().then {
    $0.backgroundColor = .clear
  }
  
  var spinner = Spinner()
  
  private(set) var isReadyForDisplay: Bool = false
  
  private var playerLayerObservation: NSKeyValueObservation?
  
  private var imageGenerator: AVAssetImageGenerator?
  
  private var hidePlayerControlTimer: Timer?
  
  // MARK: - Init
  
  deinit {
    removePlayerLayerObserver()
    hidePlayerControlTimer?.invalidate()
  }
  
  convenience init(url: URL) {
    self.init()
    self.url = url
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: - Layout
  
  override func setupViews() -> [CanBeSubview]? {
    playerControl.progress.delegate = self
    player.delegate = self
    playerControl.delegate = self
    playerView.player = player.avPlayer
    addPlayerLayerObserver()
    let tapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(togglePlayControl)
    ); view.addGestureRecognizer(tapGesture)
    
    if let url = url {
      let playerItem = AVPlayerItem(url: url)
      imageGenerator?.cancelAllCGImageGeneration()
      imageGenerator = AVAssetImageGenerator(asset: playerItem.asset)
      imageGenerator?.appliesPreferredTrackTransform = true
      imageGenerator?.maximumSize = CGSize(
        width: playerControl.popUpImageViewWidth,
        height: playerControl.popUpImageViewHeight
      )
      player.replaceCurrentItem(with: playerItem)
      player.playFromBeginning()
      playerControl.isPlaying = true
      spinner.startAnimating()
      playerControl.alpha = 0
    }
    
    return [playerView, spinner, playerControl]
  }
  
  override func setupConstraints() {
    playerView.flu
      .leftAnchor(equalTo: view.leftAnchor)
      .topAnchor(equalTo: view.topAnchor)
      .rightAnchor(equalTo: view.rightAnchor)
      .bottomAnchor(equalTo: view.bottomAnchor)
    
    playerControl.flu
      .leftAnchor(equalTo: view.leftAnchor)
      .topAnchor(equalTo: view.topAnchor)
      .rightAnchor(equalTo: view.rightAnchor)
      .bottomAnchor(equalTo: view.bottomAnchor)
    
    spinner.flu
      .centerXAnchor(equalTo: view.centerXAnchor)
      .centerYAnchor(equalTo: view.centerYAnchor)
  }
  
  @objc func togglePlayControl() {
    resetHidePlayerControlTimer()
    UIView.Animator(duration: 0.3)
      .animations { [weak self] in
        guard let `self` = self else { return }
        self.playerControl.alpha = (self.playerControl.alpha == 1.0) ? 0 : 1
      }
      .animate()
  }
  
  private func resetHidePlayerControlTimer() {
    hidePlayerControlTimer?.invalidate()
    hidePlayerControlTimer = Timer.scheduledTimer(
      timeInterval: 3,
      target: self,
      selector: #selector(callbackForScheduledTimer),
      userInfo: nil,
      repeats: false
    )
  }
  
  @objc func callbackForScheduledTimer() {
    executeBlockOnMainIfNeeded {
      UIView.Animator(duration: 0.3)
        .animations { [weak self] in
          guard let `self` = self else { return }
          if self.playerControl.progress.panState == .pan {
            return
          }
          if (self.playerControl.alpha == 0.0 && (self.player.playbackState == .paused || self.player.playbackState == .stopped)
            ) {
            return
          }
          self.playerControl.alpha = (self.player.playbackState == .playing) ? 0 : 1
        }
        .animate()
    }
  }
}

// MARK: - PlayerControlDelegate

extension PlayerViewController: PlayerControlDelegate {
  func playerControl(
    _ playerControl: PlayerControl,
    didTouchPlayButton state: PlayButtonState
  ) {
    switch state {
    case .play:
      player.playFromCurrentTime()
      
    case .pause:
      player.pause()
    }
    resetHidePlayerControlTimer()
  }
}

// MARK: - SliderDelegate

extension PlayerViewController: SliderDelegate {
  
  func sliderThumbPanDidBegin(slider: Slider) {
    UIView.Animator(duration: 0.3)
      .beforeAnimations { [weak self] in
        guard let `self` = self else { return }
        self.playerControl.popUpImageViewLeftConstraint?.constant = self.popUpViewOffsetX(forProgressValue: self.playerControl.progress.thumbValue)
      }
      .animations { [weak self] in
        guard let `self` = self else { return }
        self.playerControl.popUpImageView.alpha = 1.0
      }
      .animate()
  }
  
  func sliderThumbDidPan(slider: Slider) {
    let seconds = Double(slider.thumbValue * Float(player.durationTime))
    let dragedSeconds = CMTime(seconds: seconds, preferredTimescale: 1)
    
    if seconds > 0 {
      self.playerControl.popUpImageViewLeftConstraint?.constant =
        self.popUpViewOffsetX(forProgressValue: self.playerControl.progress.thumbValue)
      
      playerControl.popUpImageView.timeString = timeLengthString(duration: seconds)
      
      imageGenerator?.cancelAllCGImageGeneration()
      imageGenerator?.generateCGImagesAsynchronously(
        forTimes: [NSValue(time: dragedSeconds)]
      ) { requestedTime, cgImage, actualTime, result, error in
        self.executeBlockOnMainIfNeeded { [weak self] in
          guard let `self` = self else { return }
          if result == .succeeded, let cgImage = cgImage {
            self.playerControl.popUpImageView.image = UIImage(cgImage: cgImage)
          } else {
            self.playerControl.popUpImageView.backgroundColor = .black
          }
        }
      }
    }
  }
  
  func sliderThumbPanDidEnd(slider: Slider) {
    let seconds = Double(playerControl.progress.value * Float(player.durationTime))
    let seekTime = CMTime(seconds: seconds, preferredTimescale: 1)
    
    let previousPlaybackState = player.playbackState
    self.playerControl.playButton.isHidden = true
    spinner.startAnimating()
    player.pause()
    player.seek(
      to: seekTime,
      toleranceBefore: kCMTimeZero,
      toleranceAfter: kCMTimeZero
    ) { [weak self] _ in
      guard let `self` = self else { return }
      self.playerControl.playButton.isHidden = false
      self.spinner.stopAnimating()
      if previousPlaybackState == .playing {
        self.player.playFromCurrentTime()
        self.resetHidePlayerControlTimer()
      }
    }
    
    UIView.Animator(duration: 0.3)
      .animations { [weak self] in
        guard let `self` = self else { return }
        self.playerControl.popUpImageView.alpha = 0.0
      }
      .animate()
  }
  
  private func popUpViewOffsetX(forProgressValue progressValue: Float) -> CGFloat {
    // move (3% ~ 93%)
    let leftMargin = CGFloat(8); let rightMargin = CGFloat(8);
    let restrictedWidth = self.width - (leftMargin + rightMargin) - playerControl.popUpImageViewWidth
    if progressValue >= 0.03 && progressValue <= 0.93 {
      let progress = (progressValue - 0.03) / 0.90
      let offsetX = max(leftMargin + restrictedWidth * CGFloat(progress), leftMargin)
      return offsetX
    } else {
      if progressValue < 0.03 {
        return leftMargin
      }
      else {
        return self.width - (playerControl.popUpImageViewWidth + rightMargin)
      }
    }
  }
}


// MARK: - PlayerDelegate

extension PlayerViewController: PlayerDelegate {
  func player(_ player: Player, didChangePlaybackState state: PlaybackState) {
    switch state {
    case .playing:
      playerControl.isPlaying = true
    case .failed:
      playerControl.isPlaying = false
    case .paused:
      playerControl.isPlaying = false
    case .stopped:
      playerControl.isPlaying = false
    }
  }
  
  func player(_ player: Player, didChangeBufferingState state: BufferingState) {
    switch state {
    case .buffering:
      playerControl.playButton.isHidden = true
      spinner.startAnimating()
      
    case .readyToPlay:
      playerControl.playButton.isHidden = false
      spinner.stopAnimating()
      
    default: break
    }
  }
  
  func player(_ player: Player, didChangeBufferTime bufferTime: Double) {
    playerControl.progress.availableValue = Float(bufferTime / player.durationTime)
  }
  
  func player(_ player: Player, didChangeCurrentTime currentTime: Double) {
    playerControl.durationLabel.text = timeLengthString(duration: player.durationTime)
    playerControl.currentTimeLabel.text = timeLengthString(duration: player.currentTime)
    playerControl.progress.value = Float(player.currentTime / player.durationTime)
  }
  
  func playerDidEndPlayback(_ player: Player) {
    player.stop()
  }
  
  func playerWillLoopPlayback(_ player: Player) { }
}

// MARK: - Internal Helper
extension PlayerViewController {
  internal func addPlayerLayerObserver() {
    playerLayerObservation = playerView.playerLayer
      .observe(\.isReadyForDisplay) { [weak self] playerLayer, change in
        guard let `self` = self else { return }
        if self.playerView.playerLayer.isReadyForDisplay {
          self.executeBlockOnMainIfNeeded { [weak self] in
            guard let `self` = self else { return }
            self.isReadyForDisplay = true
            self.delegate?.playerViewControllerDelegateIsReadyForDisplay()
          }
        }
      }
  }
  
  internal func removePlayerLayerObserver() {
    playerLayerObservation?.invalidate()
    playerLayerObservation = nil
    view.layoutIfNeeded()
  }
  
  internal func timeLengthString(duration: TimeInterval) -> String {
    let minute = lround(duration) / 60
    let seconds = lround(duration) % 60
    let length = String(format: "%02d:%02d", minute, seconds)
    return length
  }
  
  internal func executeBlockOnMainIfNeeded(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      block()
    } else {
      DispatchQueue.main.async(execute: block)
    }
  }
}

