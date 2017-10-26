//
//  Base.swift
//  YoutubeApp
//
//  Created by myung gi son on 2017. 10. 7..
//  Copyright © 2017년 kr.go.seoul. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()?.forEach { [weak self] in
      guard let `self` = self else { return }
      if let subLayer = $0 as? CALayer {
        self.view.layer.addSublayer(subLayer)
      } else {
        self.view.addSubview($0 as! UIView)
      }
    }
    setupConstraints()
  }
  
  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupNavigationBar()
  }
  
  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateLayout()
  }
  
  open func setupNavigationBar() {}
  open func setupViews() -> [CanBeSubview]? { return nil }
  open func setupConstraints() {}
  open func updateLayout() {}
}

open class BaseCollectionViewFlowLayout: UICollectionViewFlowLayout {
  public override init() {
    super.init()
    configureLayout()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureLayout()
  }
  
  open func configureLayout() { }
}

open class BaseView: UIView {
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    updateLayout()
  }
  
  private func commonInit() {
    setupViews()?.forEach { [weak self] in
      guard let `self` = self else { return }
      if let subLayer = $0 as? CALayer {
        self.layer.addSublayer(subLayer)
      } else {
        self.addSubview($0 as! UIView)
      }
    }
    setupConstraints()
  }
  
  open func setupViews() -> [CanBeSubview]? { return nil }
  open func setupConstraints() {}
  open func updateLayout() {}
}

open class BaseCollectonViewCell: UICollectionViewCell {
  open class var cellIdentifier: String { return "\(self)" }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    updateLayout()
  }
  
  private func commonInit() {
    setupViews()?.forEach { [weak self] in
      guard let `self` = self else { return }
      if let subLayer = $0 as? CALayer {
        self.layer.addSublayer(subLayer)
      } else {
        self.addSubview($0 as! UIView)
      }
    }
    setupConstraints()
  }
  
  open func setupViews() -> [CanBeSubview]? { return nil }
  open func setupConstraints() {}
  open func updateLayout() {}
}

public protocol CanBeSubview {}
extension UIView: CanBeSubview {}
extension CALayer: CanBeSubview {}

extension UIView {
  public func addSubviews(_ subviews: UIView...) -> UIView {
    subviews.forEach { addSubview($0) }
    return self
  }
}

extension CALayer {
  public func addSublayers(_ sublayers: CALayer...) -> CALayer {
    sublayers.forEach { addSublayer($0) }
    return self
  }
}







