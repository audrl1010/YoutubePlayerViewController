//
//  FluidAnchor.swift
//
//  Created by smg on 2016. 10. 18..
//  Copyright © 2016년 grutech. All rights reserved.
//

import UIKit

// MARK: - Fluid Style AutoLayout

extension UIView {
  public var flu: FluidConstraintView {
    return FluidConstraintView(view: self)
  }
}

public struct FluidConstraintView {

  public unowned var view: UIView
  
  public init(view: UIView) {
    self.view = view
  }
  
  @discardableResult
  func translatesAutoresizingMaskIntoConstraints(isActive: Bool) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = isActive
    return self
  }
  
  @discardableResult
  func contentHuggingPriority(
    priority: UILayoutPriority,
    layoutConstraintAxis: UILayoutConstraintAxis
  ) -> FluidConstraintView {
    self.view.setContentHuggingPriority(priority, for: layoutConstraintAxis)
    return self
  }
  
  @discardableResult
  func contentCompressionResistancePriority(
    priority: UILayoutPriority,
    layoutConstraintAxis: UILayoutConstraintAxis
  ) -> FluidConstraintView {
    self.view.setContentCompressionResistancePriority(priority, for: layoutConstraintAxis)
    return self
  }
  
  @discardableResult
  func centerXAnchor(
    equalTo: NSLayoutXAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.centerXAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func centerYAnchor(
    equalTo: NSLayoutYAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.centerYAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func leadingAnchor(
    equalTo: NSLayoutXAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = false
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.leadingAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func trailingAnchor(
    equalTo: NSLayoutXAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = false
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.trailingAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func leftAnchor(
    equalTo: NSLayoutXAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.leftAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func rightAnchor(
    equalTo: NSLayoutXAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.rightAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func topAnchor(
    equalTo: NSLayoutYAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.topAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func bottomAnchor(
    equalTo: NSLayoutYAxisAnchor,
    constant: CGFloat = 0,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.bottomAnchor.constraint(
      equalTo: equalTo,
      constant: constant
    )
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func widthAnchor(
    equalTo: NSLayoutDimension,
    constant: CGFloat = 0,
    multiplier: CGFloat = 1.0,
    identifier: String? = nil,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.widthAnchor.constraint(
      equalTo: equalTo,
      multiplier: multiplier,
      constant: constant
    )
    if let identifier = identifier {
      anchor.identifier = identifier
    }
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func widthAnchor(
    equalToConstant: CGFloat,
    identifier: String? = nil,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.widthAnchor.constraint(
      equalToConstant: equalToConstant
    )
    if let identifier = identifier {
      anchor.identifier = identifier
    }
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func heightAnchor(
    equalTo: NSLayoutDimension,
    constant: CGFloat = 0,
    multiplier: CGFloat = 1.0,
    identifier: String? = nil,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.heightAnchor.constraint(
      equalTo: equalTo,
      multiplier: multiplier,
      constant: constant
    )
    if let identifier = identifier {
      anchor.identifier = identifier
    }
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  @discardableResult
  func heightAnchor(
    equalToConstant: CGFloat,
    identifier: String? = nil,
    constraint: AutoreleasingUnsafeMutablePointer<NSLayoutConstraint?>? = nil,
    isActive: Bool = true
  ) -> FluidConstraintView {
    self.view.translatesAutoresizingMaskIntoConstraints = false
    let anchor = self.view.heightAnchor.constraint(
      equalToConstant: equalToConstant
    )
    if let identifier = identifier {
      anchor.identifier = identifier
    }
    anchor.isActive = isActive
    constraint?.pointee = anchor
    return self
  }
  
  func removeAllConstraints() {
    self.view.removeConstraints(self.view.constraints)
  }
}














