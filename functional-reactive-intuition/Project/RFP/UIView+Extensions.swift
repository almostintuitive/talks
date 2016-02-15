//
//  UIView+Extensions.swift
//  RFP
//
//  Created by Daniel Morgz on 09/02/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit
import RxSwift

extension UIView {
  /**
   Bindable sink for `rotate` property.
   */
  public var rx_rotate: AnyObserver<CGFloat> {
    return AnyObserver { [weak self] event in
      MainScheduler.ensureExecutingOnScheduler()
      
      switch event {
      case .Next(let value):
        self?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, value)
      case .Error, .Completed: ()
      }
    }
  }
}

infix operator - { associativity right precedence 90 }
func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

infix operator + { associativity right precedence 90 }
func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}