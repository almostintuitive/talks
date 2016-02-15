import Foundation
import UIKit
import RxSwift
import RxCocoa


class ReactiveGestureReactor: GestureReactor {

	var delegate: GestureReactorDelegate?
	
	private var timerCreator: ReactiveTimerCreator
	
	private var panVariable: Variable<UIGestureRecognizerType?>
	private var rotateVariable: Variable<UIGestureRecognizerType?>
	
	init(timerCreator: ReactiveTimerCreator) {
		self.timerCreator = timerCreator
		panVariable = Variable(nil)
		rotateVariable = Variable(nil)
				
		// condition: when pan has begun
		let panStarted = panVariable.asObservable().filter { gesture in gesture?.state == .Began }
		// condition: when pan has ended
		let panEnded = panVariable.asObservable().filter { gesture in gesture?.state == .Ended }
		
		// condition: when rotate has begun
		let rotateStarted = rotateVariable.asObservable().filter { gesture in gesture?.state == .Began }
		// condition: when rotate has ended
		let rotateEnded = rotateVariable.asObservable().filter { gesture in gesture?.state == .Ended }
		
		// condition: when both pan and rotate has begun
		let bothGesturesStarted = Observable.combineLatest(panStarted, rotateStarted) { (_, _) -> Bool in return true }
		
		// condition: when both pan and rotate ended
		let bothGesturesEnded = Observable.of(panEnded, rotateEnded).merge()
		
		
		// when bothGesturesStarted, do this:
		bothGesturesStarted.subscribeNext { [unowned self] _ in
			
			self.delegate?.didStart()
			// create a timer that ticks every second
			let timer = self.timerCreator(interval: 1)
			// condition: but only three ticks
			let timerThatTicksThree = timer.take(3)
			// condition: and also, stop it immediately when both pan and rotate ended
			let timerThatTicksThreeAndStops = timerThatTicksThree.takeUntil(bothGesturesEnded)
			
			timerThatTicksThreeAndStops.subscribe(onNext: { [unowned self] count in
				// when a tick happens, do this:
				self.delegate?.didTick(count)
				}, onCompleted: { [unowned self] in
					// when the timer completes, do this:
					self.delegate?.didComplete()
			})
		}
	}

	func handlePan(panGesture: UIPanGestureRecognizerType) {
		panVariable.value = panGesture
	}
	
	func handleRotate(rotateGesture: UIRotationGestureRecognizerType) {
		rotateVariable.value = rotateGesture
	}
	
}