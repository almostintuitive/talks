//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReactiveViewController: UIViewController {
	
  var gestureReactor: GestureReactor?

  override func viewDidLoad() {
    super.viewDidLoad()
    
	let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
	pan.delegate = self
	let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
	pinch.delegate = self
    view.gestureRecognizers = [pan, pinch]
	
	gestureReactor = ReactiveGestureReactor(panGesture: pan, pinchGesture: pinch)
  }
	
  func handlePan(panGesture: UIPanGestureRecognizer) {
    gestureReactor?.handlePan(panGesture)
  }
	
  func handlePinch(pinchGesture: UIPinchGestureRecognizer) {
	gestureReactor?.handlePinch(pinchGesture)
  }
	
}

extension ReactiveViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
