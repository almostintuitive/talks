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

class ReactiveViewController: UIViewController, GestureReactorDelegate {
	
  var gestureReactor: GestureReactor?

  override func viewDidLoad() {
    super.viewDidLoad()
    
	let pan = UIPanGestureRecognizer()
	pan.delegate = self
	let pinch = UIPinchGestureRecognizer()
	pinch.delegate = self
    view.gestureRecognizers = [pan, pinch]
	
	gestureReactor = ReactiveGestureReactor(panGesture: pan, pinchGesture: pinch)
	gestureReactor?.delegate = self
	pan.addTarget(gestureReactor!, action: "handlePan:")
	pinch.addTarget(gestureReactor!, action: "handlePinch:")
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

extension ReactiveViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
