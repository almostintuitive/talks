import Foundation
import UIKit
import RxSwift
import RxCocoa


class ReactiveGestureReactor: GestureReactor {

	var delegate: GestureReactorDelegate?
	
	private let timerCreator: ReactiveTimerCreator
	private let disposeBag = DisposeBag()
	
    private let panVariable: Variable<UIGestureRecognizerType>
    private let rotateVariable: Variable<UIGestureRecognizerType>
	
    init(timerCreator: ReactiveTimerCreator, gestureRecognizers: (UIGestureRecognizerType, UIGestureRecognizerType)) {
		self.timerCreator = timerCreator
        self.panVariable = Variable(gestureRecognizers.0)
        self.rotateVariable = Variable(gestureRecognizers.1)
        
        // FYI 
        // Passing on the UIGesture at this point is dodgy as it's a reference 
        // It's state will change and render our filter useless. 
        // We therefore keep just the state in our observable buffers [.Began,.Began,.Ended]
        
        let rotateGesturesStartedEnded = rotateVariable.asObservable()
            .map { $0.state }
            .filter { $0 == .Began || $0 == .Ended }
        
        let panGesturesStartedEnded = panVariable.asObservable()
            .map { $0.state }
            .filter { $0 == .Began || $0 == .Ended }
        
        // Combine our latest .Began and .Ended from both Pan and Rotate.
        // If they are the same then return the same state. If not then return .Ended.
        let combinedGesture = Observable
            .combineLatest(rotateGesturesStartedEnded, panGesturesStartedEnded) { ($0, $1) }
            .map { ($0.0 == .Began && $0.1 == .Began)
                ? UIGestureRecognizerState.Began
                : UIGestureRecognizerState.Ended
            }
            .map { state -> UIGestureRecognizerState in
                print(state)
                return state }
            .distinctUntilChanged()
            // several .Began events in a row are to be treated the same as a single one, it has just meaning if a .Ended is in between
        
        // condition: when both pan and rotate has begun
        let bothGesturesStarted = combinedGesture.filter { $0 == .Began }
        
        // condition: when both pan and rotate has Ended
        let bothGesturesEnded = combinedGesture.filter { $0 == .Ended }
        
		// when bothGesturesStarted, do this:
		bothGesturesStarted.subscribeNext { [unowned self] _ in
			
			self.delegate?.didStart()
			// create a timer that ticks every second
			let timer = self.timerCreator(interval: 1)
			// condition: but only three ticks
			let timerThatTicksThree = timer.take(4)
			// condition: and also, stop it immediately when both pan and rotate ended
			let timerThatTicksThreeAndStops = timerThatTicksThree.takeUntil(bothGesturesEnded)
			
            timerThatTicksThreeAndStops
                // the imperative version waits for a second until didComplete is called, so we have to tick once more, but do not send the last tick to the delegate
                .filter { $0 < 3 }
                .subscribe(onNext: { [unowned self] count in
                    // when a tick happens, do this:
                    self.delegate?.didTick(2 - count)
				}, onCompleted: { [unowned self] in
					// when the timer completes, do this:
					self.delegate?.didComplete()
                })
		}.addDisposableTo(self.disposeBag)

	}

	func handlePan(panGesture: UIPanGestureRecognizerType) {
		panVariable.value = panGesture
	}
	
	func handleRotate(rotateGesture: UIRotationGestureRecognizerType) {
		rotateVariable.value = rotateGesture
	}
	
}