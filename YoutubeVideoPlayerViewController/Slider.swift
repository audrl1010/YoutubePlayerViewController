//
//  Slider.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit

// MARK: - Delegate

protocol SliderDelegate: class {
  func sliderThumbPanDidBegin(slider: Slider)
  func sliderThumbDidPan(slider: Slider)
  func sliderThumbPanDidEnd(slider: Slider)
}

// MARK: - State

enum PanState: String {
  case none
  case pan
  case end
  case begin
}

// MARK: - Slider

class Slider: BaseView {
  
  // MARK: - Constants
  
  struct Value {
    static let thumbCornerRadius = 8.f
    static let thumbBorderWidth = 0.f
    static let trackCornerRadius = 1.f
    static let trackBorderWidth = 2.f
  }
  struct Metric {
    static let trackHeight = 2.f
    static let thumbWidth = 16.f
    static let thumbHeight = 16.f
  }
  struct Color {
    static let minimumTrackViewTintColor = UIColor(white: 0.9, alpha: 1)
    static let maximumTrackViewTintColor = UIColor(white: 0.7, alpha: 1)
    static let availableTrackTintColor = UIColor(white: 0.5, alpha: 1)
    static let thumbTintColor = UIColor.white
    static let thumbBorderColor = UIColor.clear.cgColor
  }
  
  // MARK: - Properties
  
  weak var delegate: SliderDelegate?
  
  var value: Float = 0 { didSet { updateValue() } }
  var minimumValue: Float = 0 { didSet { updateValue() } }
  var maximumValue: Float = 1 { didSet { updateValue() } }
  var availableValue: Float = 0 { didSet { updateValue() } }
  
  private(set) var thumbValue: Float = 0
  private(set) var panState: PanState = .none
  
  // MARK: - UIs
  
  let minimumTrackView = UIView().then {
    $0.backgroundColor = Color.minimumTrackViewTintColor
    $0.layer.cornerRadius = Value.trackCornerRadius
    $0.clipsToBounds = true
  }
  let maximumTrackView = UIView().then {
    $0.backgroundColor = Color.maximumTrackViewTintColor
    $0.layer.cornerRadius = Value.trackCornerRadius
    $0.clipsToBounds = true
  }
  let availableTrackView = UIView().then {
    $0.backgroundColor = Color.availableTrackTintColor
    $0.layer.cornerRadius = Value.trackCornerRadius
    $0.clipsToBounds = true
  }
  let thumbView = UIView().then {
    $0.backgroundColor = .gray
    $0.clipsToBounds = true
    $0.layer.cornerRadius = Value.thumbCornerRadius
    $0.layer.borderColor = Color.thumbBorderColor
    $0.layer.borderWidth = Value.thumbBorderWidth
  }
  
  private var availableTrackViewWidthConstraint: NSLayoutConstraint?
  private var minimumTrackViewWidthConstraint: NSLayoutConstraint?
  private var thumbViewLeftConstraint: NSLayoutConstraint?
  
  // MARK: - Layout
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: 22.f)
  }
  
  override func setupViews() -> [CanBeSubview]? {
    let panGestureRecognizer = UIPanGestureRecognizer(
      target: self,
      action: #selector(viewDidPan(_:))
    ); addGestureRecognizer(panGestureRecognizer)
    
    return [
      maximumTrackView
        .addSubviews(availableTrackView, minimumTrackView),
      thumbView
    ]
  }
  
  override func setupConstraints() {
    maximumTrackView.flu
      .leftAnchor(equalTo: leftAnchor)
      .centerYAnchor(equalTo: centerYAnchor)
      .widthAnchor(equalTo: widthAnchor)
      .heightAnchor(equalToConstant: Metric.trackHeight)
    
    availableTrackView.flu
      .leftAnchor(equalTo: maximumTrackView.leftAnchor)
      .topAnchor(equalTo: maximumTrackView.topAnchor)
      .widthAnchor(
        equalToConstant: 0,
        constraint: &availableTrackViewWidthConstraint
      )
      .heightAnchor(equalToConstant: Metric.trackHeight)
    
    minimumTrackView.flu
      .leftAnchor(equalTo: maximumTrackView.leftAnchor)
      .topAnchor(equalTo: maximumTrackView.topAnchor)
      .widthAnchor(
        equalToConstant: 0,
        constraint: &minimumTrackViewWidthConstraint
      )
      .heightAnchor(equalToConstant: Metric.trackHeight)
    
    thumbView.flu
      .leftAnchor(
        equalTo: leftAnchor,
        constraint: &thumbViewLeftConstraint
      )
      .centerYAnchor(equalTo: centerYAnchor)
      .widthAnchor(equalToConstant: Metric.thumbWidth)
      .heightAnchor(equalToConstant: Metric.thumbHeight)
  }
  
  // MARK: - Public Methods
  
  func setValue(_ value: Float, animatedForDuration duration: TimeInterval) {
    self.value = value
    if duration > 0 {
      UIView
        .Animator(duration: duration)
        .options(.allowUserInteraction)
        .animations { [weak self] in
          guard let `self` = self else { return }
          self.layoutIfNeeded()
        }
        .animate()
    }
  }
  
  func setAvailableValue(_ value: Float, animatedForDuration duration: TimeInterval) {
    self.availableValue = value
    if duration > 0 {
      UIView
        .Animator(duration: duration)
        .animations { [weak self] in
          guard let `self` = self else { return }
          self.layoutIfNeeded()
        }
        .animate()
    }
  }
  
  // MARK: - Private Methods
  
  private func updateValue() {
    let realMaximumValue = max(0.00001, CGFloat(maximumValue - minimumValue))
    let realAvailableValue = max(0, min(realMaximumValue, CGFloat(availableValue - minimumValue)))
    let realValue = max(0, min(realMaximumValue, CGFloat(value - minimumValue)))
    
    availableTrackViewWidthConstraint?.constant = maximumTrackView.width * (realAvailableValue / realMaximumValue)
    minimumTrackViewWidthConstraint?.constant = maximumTrackView.width * (realValue / realMaximumValue)
    
    if (panState != .pan) {
      thumbViewLeftConstraint?.constant = (maximumTrackView.width - Metric.thumbWidth) * (realValue / realMaximumValue)
      thumbValue = Float(realValue)
    }
  }
  
  // MARK: - Actions
  
  @objc func viewDidPan(_ recognizer: UIPanGestureRecognizer) {
    let location = recognizer.location(in: self)
    let trackWidth = maximumTrackView.width - Metric.thumbWidth
    if recognizer.state == .began {
      panState = .begin
      delegate?.sliderThumbPanDidBegin(slider: self)
    }
    if recognizer.state == .changed ||
      recognizer.state == .ended ||
      recognizer.state == .cancelled {
      var targetX = location.x
      
      if targetX < 0 {
        targetX = 0
      }
      else if targetX > trackWidth {
        targetX = trackWidth
      }
      
      thumbValue = Float(targetX / trackWidth)
      
      thumbView.x = targetX
      
      if recognizer.state == .changed {
        panState = .pan
        delegate?.sliderThumbDidPan(slider: self)
      }
      else {
        value = minimumValue + (maximumValue - minimumValue) * Float(targetX / trackWidth)
        panState = .end
        delegate?.sliderThumbPanDidEnd(slider: self)
        panState = .none
      }
    }
  }
}
