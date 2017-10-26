//
//  PopUpImageView.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit

class PopUpImageView: BaseView {
  var image: UIImage? = nil {
    didSet { imageView.image = image }
  }
  
  var timeString: String? = nil {
    didSet { timeLabel.text = timeString }
  }
  
  var imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
  }
  var timeLabel = UILabel().then {
    $0.textColor = .white
    $0.font = UIFont.boldSystemFont(ofSize: 13)
    $0.textAlignment = .center
  }
  
  override func setupViews() -> [CanBeSubview]? {
    return [
      imageView,
      timeLabel
    ]
  }
  
  override func setupConstraints() {
    imageView.flu
      .topAnchor(equalTo: topAnchor)
      .leftAnchor(equalTo: leftAnchor)
      .rightAnchor(equalTo: rightAnchor)
      .bottomAnchor(equalTo: bottomAnchor)
    
    timeLabel.flu
      .bottomAnchor(
        equalTo: imageView.bottomAnchor,
        constant: -8
      )
      .leftAnchor(equalTo: leftAnchor)
      .rightAnchor(equalTo: rightAnchor)
  }
}
