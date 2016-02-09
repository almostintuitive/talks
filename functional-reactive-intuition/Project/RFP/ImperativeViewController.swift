//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ImperativeViewController: UIViewController, UIGestureRecognizerDelegate, GestureReactorDelegate {
	
  var gestureReactor: GestureReactor = ImperativeGestureReactor()
	
  override func viewDidLoad() {
    super.viewDidLoad()
    let pan = UIPanGestureRecognizer(target: gestureReactor, action: "handlePan:")
    pan.delegate = self
    let pinch = UIPinchGestureRecognizer(target: gestureReactor, action: "handlePinch:")
    pinch.delegate = self
    view.gestureRecognizers = [pan, pinch]
	gestureReactor.delegate = self
  }
    
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
	
  func didStart() {
    print("started")
  }

  func didTick(count: Int) {
    print("tick \(count)")
  }

  func didComplete() {
    print("completed")
  }

}
