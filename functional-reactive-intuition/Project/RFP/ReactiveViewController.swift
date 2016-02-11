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
	
	var gestureReactor: GestureReactor = ReactiveGestureReactor()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		gestureReactor.delegate = self
		let pan = UIPanGestureRecognizer(target: gestureReactor, action: "handlePan:")
		pan.delegate = self
		let pinch = UIPinchGestureRecognizer(target: gestureReactor, action: "handlePinch:")
		pinch.delegate = self
		view.gestureRecognizers = [pan, pinch]
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
