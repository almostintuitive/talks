import Foundation
import UIKit
import RxSwift
import RxCocoa


@objc class ReactiveGestureReactor: NSObject, GestureReactor {

	var panVariable: Variable<UIGestureRecognizer>
	var pinchVariable: Variable<UIGestureRecognizer>
	
	init(panGesture: UIPanGestureRecognizer, pinchGesture: UIPinchGestureRecognizer) {
		panVariable = Variable(panGesture)
		pinchVariable = Variable(pinchGesture)
		
		// condition: when pan has begun
		let panStarted = panVariable.asObservable().filter { gesture in gesture.state == .Began }
		// condition: when pan has ended
		let panEnded = panVariable.asObservable().filter { gesture in gesture.state == .Ended }
		
		// condition: when pinch has begun
		let pinchStarted = pinchVariable.asObservable().filter { gesture in gesture.state == .Began }
		// condition: when pinch has ended
		let pinchEnded = pinchVariable.asObservable().filter { gesture in gesture.state == .Ended }
		
		// condition: when both pan and pinch has begun
		let bothGesturesStarted = Observable.combineLatest(panStarted, pinchStarted) { (_, _) -> Bool in return true }
		
		// condition: when both pan and pinch ended
		let bothGesturesEnded = Observable.of(panEnded, pinchEnded).merge()
		
		
		// when bothGesturesStarted, do this:
		bothGesturesStarted.subscribeNext { _ in
			
			print("started")
			// create a timer that ticks every second
			let timer = Observable<Int>.timer(repeatEvery: 1)
			// condition: but only three ticks
			let timerThatTicksThree = timer.take(3)
			// condition: and also, stop it immediately when both pan and pinch ended
			let timerThatTicksThreeAndStops = timerThatTicksThree.takeUntil(bothGesturesEnded)
			
			timerThatTicksThreeAndStops.subscribe(onNext: { count in
				// when a tick happens, do this:
				print("tick: \(count)")
				}, onCompleted: {
					// when the timer completes, do this:
					print("completed")
			})
		}
	}

	func handlePan(panGesture: UIPanGestureRecognizer) {
		panVariable.value = panGesture
	}
	
	func handlePinch(pinchGesture: UIPinchGestureRecognizer) {
		pinchVariable.value = pinchGesture
	}
	
}