import Foundation
import UIKit
import RxSwift
@testable import RFP


class MockGestureReactorDelegate: GestureReactorDelegate {

	var didStartCalled = 0
	var didTickCalled = 0
	var didCompleteCalled = 0
	var tickSecondsLefts: [Int] = []
	
	func didStart() {
		didStartCalled += 1
	}
	
	func didTick(secondsLeft: Int) {
		didTickCalled += 1
		tickSecondsLefts.append(secondsLeft)
	}
	
	func didComplete() {
		didCompleteCalled += 1
	}

}


class MockTimer: TimerType {
	
	private let onTick: TimerTicker
	
	var invalidateCalled = 0
	
	init(interval: NSTimeInterval, repeats: Bool, onTick: TimerTicker) {
		precondition(repeats)
		self.onTick = onTick
	}
	
	func mockExecuteOnTick() {
		onTick(sender: self)
	}
	
	func invalidate() {
		invalidateCalled += 1
	}
	
}


class MockReactiveTimer: Variable<Int> {
	
	var invalidateCalled = 0

	init(interval: NSTimeInterval) {
        // needs to be -1 in order for first tick being 0
		super.init(-1)
	}
	
	func mockExecuteOnTick() {
		value += 1
	}
	
	func invalidate() {
		invalidateCalled += 1
	}
	
}


class MockPanGestureRecognizer: UIPanGestureRecognizerType {
	
	var state: UIGestureRecognizerState
	
	init(state: UIGestureRecognizerState) {
		self.state = state
	}

}


class MockRotateGestureRecognizer: UIRotationGestureRecognizerType {
	
	var state: UIGestureRecognizerState
	
	init(state: UIGestureRecognizerState) {
		self.state = state
	}

}

