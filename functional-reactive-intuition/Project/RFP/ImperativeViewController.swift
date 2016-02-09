//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ImperativeViewController: UIViewController, UIGestureRecognizerDelegate {
	
  var gestureReactor = ImperativeGestureReactor()
	
  override func viewDidLoad() {
    super.viewDidLoad()
    let pan = UIPanGestureRecognizer(target: gestureReactor, action: "handlePan:")
    pan.delegate = self
    let pinch = UIPinchGestureRecognizer(target: gestureReactor, action: "handlePinch:")
    pinch.delegate = self
    view.gestureRecognizers = [pan, pinch]
  }
    
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
    
}
