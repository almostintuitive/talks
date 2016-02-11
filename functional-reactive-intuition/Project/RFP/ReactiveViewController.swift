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
	
	private var gestureReactor: GestureReactor = ReactiveGestureReactor(timerCreator: { interval in ReactiveTimerFactory.reactiveTimer(interval: interval) })
	
	override func viewDidLoad() {
		super.viewDidLoad()
		gestureReactor.delegate = self
		let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
		pan.delegate = self
		let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
		pinch.delegate = self
		view.gestureRecognizers = [pan, pinch]
	}
	
	// cannot be private due to use of target-action
	func handlePan(panGesture: UIPanGestureRecognizer) {
		gestureReactor.handlePan(panGesture)
	}
	
	// cannot be private due to use of target-action
	func handlePinch(pinchGesture: UIPinchGestureRecognizer) {
		gestureReactor.handlePinch(pinchGesture)
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
