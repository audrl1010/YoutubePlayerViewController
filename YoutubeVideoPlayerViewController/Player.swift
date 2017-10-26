//
//  Player.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - PlayerDelegate

protocol PlayerDelegate: class {
  func player(_ player: Player, didChangePlaybackState state: PlaybackState)
  func player(_ player: Player, didChangeBufferingState state: BufferingState)
  func player(_ player: Player, didChangeBufferTime bufferTime: Double)
  func player(_ player: Player, didChangeCurrentTime currentTime: Double)
  func playerWillStartPlaybackFromBeginning(_ player: Player)
  func playerDidEndPlayback(_ player: Player)
  func playerWillLoopPlayback(_ player: Player)
}

extension PlayerDelegate {
  func player(_ player: Player, didChangePlaybackState state: PlaybackState) {}
  func player(_ player: Player, didChangeBufferingState state: BufferingState) {}
  func player(_ player: Player, didChangeBufferTime bufferTime: Double) {}
  func player(_ player: Player, didChangeCurrentTime currentTime: Double) {}
  func playerWillStartPlaybackFromBeginning(_ player: Player) {}
  func playerDidEndPlayback(_ player: Player) {}
  func playerWillLoopPlayback(_ player: Player) {}
}

// MARK: - State

enum BufferingState: String {
  case unknown
  case readyToPlay
  case buffering
}

enum PlaybackState: String {
  case stopped
  case playing
  case paused
  case failed
}

// MARK: - Player

class Player: NSObject {
  
  // MARK: - Public Properties
  
  weak var delegate: PlayerDelegate?
  
  private(set) var url: URL?
  
  private(set) var currentPlayerItem: AVPlayerItem?
  
  private(set) var asset: AVAsset?
  
  lazy var avPlayer = AVPlayer().then {
    $0.actionAtItemEnd = .pause
  }
  
  var playbackFreezesAtEnd: Bool = true
  
  var playbackPausesWhenBackgrounded: Bool = true
  
  var playbackResumesWhenEnteringForeground: Bool = true
  
  var playbackResumesWhenBecameActive: Bool = true
  
  var playbackState: PlaybackState = .stopped {
    didSet {
      if playbackState != oldValue {
        self.delegate?.player(self, didChangePlaybackState: playbackState)
      }
    }
  }
  
  var bufferingState: BufferingState = .unknown {
    didSet {
      if bufferingState != oldValue {
        self.delegate?.player(self, didChangeBufferingState: bufferingState)
      }
    }
  }
  
  var isMuted: Bool {
    get { return avPlayer.isMuted }
    set(new) { avPlayer.isMuted = new }
  }
  
  var volume: Float {
    get { return avPlayer.volume }
    set(new) { avPlayer.volume = new }
  }
  
  var durationTime: TimeInterval {
    if let currentItem = avPlayer.currentItem {
      return CMTimeGetSeconds(currentItem.duration)
    } else {
      return CMTimeGetSeconds(kCMTimeIndefinite)
    }
  }
  
  var currentTime: TimeInterval {
    if let currentItem = avPlayer.currentItem {
      return CMTimeGetSeconds(currentItem.currentTime())
    } else {
      return CMTimeGetSeconds(kCMTimeIndefinite)
    }
  }
  
  var playbackLoops: Bool {
    get { return (avPlayer.actionAtItemEnd == .none) as Bool }
    set(new) {
      avPlayer.actionAtItemEnd =
        (new == true) ? .none : .pause
    }
  }
  
  var naturlSize: CGSize {
    if let currentPlayerItem = self.currentPlayerItem,
      let track = currentPlayerItem.asset.tracks(withMediaType: .video).first {
      let size = track.naturalSize.applying(track.preferredTransform)
      return CGSize(width: fabs(size.width), height: fabs(size.height))
    } else {
      return .zero
    }
  }
  
  // MARK: - Private Properties
  
  private var seekTimeRequested: CMTime?
  
  private var timeObserver: Any? = nil
  
  private var lastBufferTime: Double = 0.0
  
  private var currentPlayerItemObservations: [NSKeyValueObservation] = []
  
  private var didRemovePlayerObservers: (() -> Void)?
  
  // MARK: - Initializing
  override init() {
    super.init()
    addApplicationObservers()
    addPlayerObservers()
  }
  
  deinit {
    avPlayer.pause()
    removeCurrentPlayerItemObservers()
    removePlayerObservers()
    removeApplicationObservers()
    delegate = nil
  }
  
  func replaceCurrentItem(with newItem: AVPlayerItem) {
    if playbackState == .playing {
      pause()
    }
    removeCurrentPlayerItemObservers()
    removePlayerObservers()
    
    if #available(iOS 9.0, *) {
      newItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
    }
    self.asset = newItem.asset
    currentPlayerItem = newItem
    avPlayer.replaceCurrentItem(with: newItem)
    
    let keys = ["tracks", "playable", "duration"]
    newItem.asset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
      guard let `self` = self else { return }
      for key in keys {
        var error: NSError? = nil
        let status = self.asset?.statusOfValue(forKey: key, error: &error)
        if status == .failed {
          self.executeBlockOnMainIfNeeded { [weak self] in
            guard let `self` = self else { return }
            self.playbackState = .failed
          }
          return
        }
      }
    }
    
    if let seek = self.seekTimeRequested {
      self.seekTimeRequested = nil
      self.seek(to: seek)
    }
    
    self.avPlayer.actionAtItemEnd = (self.playbackLoops == true)
      ? .none
      : .pause
    self.addPlayerItemObservers(newItem)
    self.addPlayerObservers()
  }
  
  func replaceCurrentItem(with url: URL) {
    if playbackState == .playing {
      pause()
    }
    removeCurrentPlayerItemObservers()
    removePlayerObservers()
    currentPlayerItem = nil
    
    bufferingState = .unknown
    asset = AVAsset(url: url)
    let keys = ["tracks", "playable", "duration"]
    asset?.loadValuesAsynchronously(forKeys: keys) { [weak self] in
      guard let `self` = self else { return }
      for key in keys {
        var error: NSError? = nil
        let status = self.asset?.statusOfValue(forKey: key, error: &error)
        if status == .failed {
          self.executeBlockOnMainIfNeeded { [weak self] in
            guard let `self` = self else { return }
            self.playbackState = .failed
          }
          return
        }
      }
      if let asset = self.asset {
        if asset.isPlayable == false {
          self.executeBlockOnMainIfNeeded { [weak self] in
            guard let `self` = self else { return }
            self.playbackState = .failed
          }
          return
        }
        let newPlayerItem = AVPlayerItem(asset: asset)
        self.currentPlayerItem = newPlayerItem
        if #available(iOS 9.0, *) {
          newPlayerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        }
        if let seek = self.seekTimeRequested {
          self.seekTimeRequested = nil
          self.seek(to: seek)
        }
        self.avPlayer.replaceCurrentItem(with: newPlayerItem)
        self.avPlayer.actionAtItemEnd = (self.playbackLoops == true)
          ? .none
          : .pause
        self.addPlayerItemObservers(newPlayerItem)
        self.addPlayerObservers()
      }
    }
  }
  
  func playFromBeginning() {
    delegate?.playerWillStartPlaybackFromBeginning(self)
    avPlayer.seek(to: kCMTimeZero)
    playFromCurrentTime()
  }
  
  func playFromCurrentTime() {
    playbackState = .playing
    avPlayer.play()
  }
  
  func pause() {
    guard playbackState == .playing else { return }
    avPlayer.pause()
    playbackState = .paused
  }
  
  func stop() {
    
    guard playbackState == .stopped else { return }
    avPlayer.pause()
    playbackState = .stopped
    delegate?.playerDidEndPlayback(self)
  }
  
  func seek(to time: CMTime, completion: (() -> Void)? = nil) {
    if let currentPlayerItem = currentPlayerItem {
      currentPlayerItem.seek(to: time) { seeked in
        completion?()
      }
    } else {
      seekTimeRequested = time
    }
  }
  
  func seek(
    to time: CMTime,
    toleranceBefore: CMTime,
    toleranceAfter: CMTime,
    completion: ((_ seeked: Bool) -> Void)? = nil
  ) {
    if let currentPlayerItem = currentPlayerItem {
      currentPlayerItem.seek(
        to: time,
        toleranceBefore: toleranceBefore,
        toleranceAfter: toleranceAfter
      ) { seeked in
        completion?(seeked)
      }
    } else {
      seekTimeRequested = time
    }
  }
}

// MARK: - Internal Helper
extension Player {
  private func addApplicationObservers() {
    NotificationCenter.default.do {
      $0.addObserver(
        forName: .UIApplicationWillResignActive,
        object: UIApplication.shared,
        queue: .main
      ) { [weak self] notification in
        guard let `self` = self else { return }
        if self.playbackState == .playing {
          self.pause()
        }
      }
      $0.addObserver(
        forName: .UIApplicationDidEnterBackground,
        object: UIApplication.shared,
        queue: .main
      ) { [weak self] notification in
        guard let `self` = self else { return }
        if self.playbackState == .playing && self.playbackPausesWhenBackgrounded {
          self.pause()
        }
      }
      $0.addObserver(
        forName: .UIApplicationWillEnterForeground,
        object: UIApplication.shared,
        queue: .main
      ) { [weak self] notification in
        guard let `self` = self else { return }
        if self.playbackState != .playing && self.playbackResumesWhenEnteringForeground {
          self.playFromCurrentTime()
        }
      }
      $0.addObserver(
        forName: .UIApplicationDidBecomeActive,
        object: UIApplication.shared,
        queue: .main
      ) { [weak self] notification in
        guard let `self` = self else { return }
        if self.playbackState != .playing && self.playbackResumesWhenBecameActive {
          self.playFromCurrentTime()
        }
      }
    }
  }
  
  private func removeApplicationObservers() {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func addPlayerItemObservers(_ newItem: AVPlayerItem) {
    let isPlaybackLikelyToKeepUpObservation =
      newItem.observe(\.isPlaybackLikelyToKeepUp) { [weak self] playerItem, change in
        guard let `self` = self else { return }
        if playerItem.isPlaybackLikelyToKeepUp {
          self.bufferingState = .readyToPlay
          if self.playbackState == .playing {
            self.playFromCurrentTime()
          }
        }
      }
    
    let isPlaybackBufferEmptyObservation =
      newItem.observe(\.isPlaybackBufferEmpty) { [weak self] playerItem, change in
        guard let `self` = self else { return }
        if playerItem.isPlaybackBufferEmpty {
          self.bufferingState = .buffering
        }
      }
    
    let loadedTimeRangesObservation =
      newItem.observe(\.loadedTimeRanges) { [weak self] playerItem, change in
        guard let `self` = self else { return }
        let loadedTimeRange = playerItem.loadedTimeRanges
        if let timeRange = loadedTimeRange.first?.timeRangeValue {
          let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
          if self.lastBufferTime != bufferedTime {
            self.lastBufferTime = bufferedTime
            DispatchQueue.main.async { [weak self] in
              guard let `self` = self else { return }
              self.delegate?.player(self, didChangeBufferTime: bufferedTime)
            }
          }
        }
      }
    currentPlayerItemObservations += [
      isPlaybackBufferEmptyObservation,
      isPlaybackLikelyToKeepUpObservation,
      loadedTimeRangesObservation
    ]
    NotificationCenter.default.do {
      $0.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime,
        object: newItem,
        queue: .main
      ) { [weak self] notification in
        guard let `self` = self else { return }
        if self.playbackLoops == true {
          self.delegate?.playerWillLoopPlayback(self)
          self.avPlayer.seek(to: kCMTimeZero)
        }
        else {
          if self.playbackFreezesAtEnd == true {
            self.stop()
          } else {
            self.avPlayer.seek(to: kCMTimeZero
            ) { [weak self] _ in
              guard let `self` = self else { return }
              self.stop()
            }
          }
        }
      }
      $0.addObserver(
        forName: .AVPlayerItemFailedToPlayToEndTime,
        object: newItem,
        queue: .main
      ) { [weak self] _ in
        guard let `self` = self else { return }
        self.playbackState = .failed
      }
    }
  }
  
  private func removeCurrentPlayerItemObservers() {
    currentPlayerItemObservations.forEach { $0.invalidate() }
    if let currentPlayerItem = currentPlayerItem {
      NotificationCenter.default.do {
        $0.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentPlayerItem)
        $0.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: currentPlayerItem)
      }
    }
  }
  
  private func addPlayerObservers() {
    timeObserver = avPlayer.addPeriodicTimeObserver(
      forInterval: CMTimeMake(1, 100),
      queue: .main
    ) { [weak self] timeInterval in
      guard let `self` = self else { return }
      self.delegate?.player(self, didChangeCurrentTime: self.currentTime)
    }
  }
  
  private func removePlayerObservers() {
    if let observer = timeObserver {
      avPlayer.removeTimeObserver(observer)
    }
    didRemovePlayerObservers?()
  }
  
  internal func executeBlockOnMainIfNeeded(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      block()
    } else {
      DispatchQueue.main.async(execute: block)
    }
  }
}
