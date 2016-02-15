//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ImperativeViewController: UIViewController, UIGestureRecognizerDelegate, GestureReactorDelegate {
	
	private var gestureReactor: GestureReactor = ImperativeGestureReactor(timerCreator: { interval, repeats, onTick in Timer(interval: interval, repeats: repeats, onTick: onTick) })
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
		pan.delegate = self
		let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
		pinch.delegate = self
		view.gestureRecognizers = [pan, pinch]
		gestureReactor.delegate = self
	}
	
	@objc private func handlePan(panGesture: UIPanGestureRecognizer) {
		gestureReactor.handlePan(panGesture)
	}
	
	@objc private func handlePinch(pinchGesture: UIPinchGestureRecognizer) {
		gestureReactor.handlePinch(pinchGesture)
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
