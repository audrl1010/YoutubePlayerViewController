//
//  MainViewController.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  var playerViewController = PlayerViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addChildViewController(playerViewController)
    view.addSubview(playerViewController.view)
    playerViewController.view.flu
      .topAnchor(equalTo: view.topAnchor)
      .leftAnchor(equalTo: view.leftAnchor)
      .rightAnchor(equalTo: view.rightAnchor)
      .bottomAnchor(equalTo: view.bottomAnchor)
    playerViewController.didMove(toParentViewController: self)
    
    playerViewController.url = URL(string: "http://baobab.wdjcdn.com/1458625865688ONE.mp4")!
  }
}
