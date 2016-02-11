import Foundation
import UIKit


@objc class ImperativeGestureReactor: NSObject, GestureReactor {
	
	var delegate: GestureReactorDelegate?
	
	var timerCreator: TimerCreator
	
	var panPresent = false
	var pinchPresent = false
	var gestureTimer: TimerType?
	var secondsLeft = 3

	init(timerCreator: TimerCreator) {
		self.timerCreator = timerCreator
		super.init()
	}
	
	func handlePan(panGesture: UIPanGestureRecognizerType) {
		if panGesture.state == .Began && self.panPresent == false {
			self.panPresent = true
			self.checkIfBothGesturesPresent()
		} else if panGesture.state == .Ended {
			self.panPresent = false
			self.stopTimerIfNeeded()
		}
	}
	
	func handlePinch(pinchGesture: UIPinchGestureRecognizerType) {
		if pinchGesture.state == .Began && self.pinchPresent == false {
			self.pinchPresent = true
			self.checkIfBothGesturesPresent()
		} else if pinchGesture.state == .Ended {
			self.pinchPresent = false
			self.stopTimerIfNeeded()
		}
	}
	
	func checkIfBothGesturesPresent() {
		if self.pinchPresent == true && self.panPresent == true && self.gestureTimer == nil {
			self.secondsLeft = 3
			self.gestureTimer = timerCreator(interval: 1, repeats: true, onTick: { [weak self] sender in
				self?.tick(sender)
			})
			delegate?.didStart()
		}
	}
	
	func stopTimerIfNeeded() {
		if let gestureTimer = gestureTimer {
			gestureTimer.invalidate()
			self.gestureTimer = nil
			delegate?.didComplete()
		}
	}
	
	func tick(timer: TimerType) {
		if self.secondsLeft <= 0 {
			self.stopTimerIfNeeded()
			return
		}
		self.secondsLeft--
		delegate?.didTick(0)
	}

}