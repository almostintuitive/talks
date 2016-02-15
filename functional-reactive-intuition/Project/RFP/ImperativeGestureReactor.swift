import Foundation
import UIKit


class ImperativeGestureReactor: GestureReactor {
	
	var delegate: GestureReactorDelegate?
	
	private var timerCreator: TimerCreator
	
	private var panPresent = false
	private var pinchPresent = false
	private var gestureTimer: TimerType?
	private var secondsLeft = 3
	private var tickCount = 0

	init(timerCreator: TimerCreator) {
		self.timerCreator = timerCreator
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
	
	func handleRotate(rotateGesture: UIRotationGestureRecognizerType) {
		if rotateGesture.state == .Began && self.pinchPresent == false {
			self.pinchPresent = true
			self.checkIfBothGesturesPresent()
		} else if rotateGesture.state == .Ended {
			self.pinchPresent = false
			self.stopTimerIfNeeded()
		}
	}
	
	private func checkIfBothGesturesPresent() {
		if self.pinchPresent == true && self.panPresent == true && self.gestureTimer == nil {
			self.secondsLeft = 3
			self.gestureTimer = timerCreator(interval: 1, repeats: true, onTick: { [weak self] sender in
				self?.tick(sender)
			})
			delegate?.didStart()
		}
	}
	
	private func stopTimerIfNeeded() {
		if let gestureTimer = gestureTimer {
			gestureTimer.invalidate()
			self.gestureTimer = nil
			self.tickCount = 0
			delegate?.didComplete()
		}
	}
	
	private func tick(timer: TimerType) {
		if self.secondsLeft <= 0 {
			self.stopTimerIfNeeded()
			return
		}
		self.secondsLeft--
		delegate?.didTick(tickCount)
		tickCount += 1
	}

}