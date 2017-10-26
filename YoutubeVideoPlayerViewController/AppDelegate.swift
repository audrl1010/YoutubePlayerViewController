//
//  AppDelegate.swift
//  YoutubeVideoPlayerViewController
//
//  Created by myung gi son on 2017. 10. 26..
//  Copyright © 2017년 com.smg. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions
    launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    setupApplication(application)
    return true
  }
  
  func setupApplication(_ application: UIApplication) {
    application.statusBarStyle = .lightContent
    window = UIWindow(frame: UIScreen.main.bounds).then {
      $0.rootViewController = MainViewController()
      $0.makeKeyAndVisible()
    }
  }
}

