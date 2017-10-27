//
//  Spinner.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 27..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit

class Spinner: BaseView {
  let ovalShapeLayer = CAShapeLayer().then {
    $0.strokeColor = UIColor.white.cgColor
    $0.fillColor = UIColor.clear.cgColor
    $0.lineWidth = 3.0
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: 40.0, height: 40.0)
  }
  
  override func setupViews() -> [CanBeSubview]? {
    ovalShapeLayer.opacity = 0
    return [ovalShapeLayer]
  }
  
  override func updateLayout() {
    ovalShapeLayer.path = UIBezierPath(ovalIn: CGRect(
        x: 0,
        y: 0,
        width: intrinsicContentSize.width,
        height: intrinsicContentSize.height
      )
    ).cgPath
  }
  
  func startAnimating() {
    ovalShapeLayer.opacity = 1
    let strokeStartAnimation = CABasicAnimation(
      keyPath: "strokeStart"
    )
    strokeStartAnimation.fromValue = -0.5
    strokeStartAnimation.toValue = 1.0
    
    let strokeEndAnimation = CABasicAnimation(
      keyPath: "strokeEnd"
    )
    strokeEndAnimation.fromValue = 0.0
    strokeEndAnimation.toValue = 1.0
    
    let strokeAnimationGroup = CAAnimationGroup()
    
    strokeAnimationGroup.repeatCount = Float.greatestFiniteMagnitude
    strokeAnimationGroup.duration = 1.5
    strokeAnimationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
    ovalShapeLayer.add(strokeAnimationGroup, forKey: nil)
  }
  
  func stopAnimating() {
    ovalShapeLayer.opacity = 0
    ovalShapeLayer.removeAllAnimations()
  }
}
