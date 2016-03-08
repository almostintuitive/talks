import Foundation
import UIKit
import RxSwift
import RxCocoa


class ReactiveGestureReactor: GestureReactor {

	var delegate: GestureReactorDelegate?
	
	private let timerCreator: ReactiveTimerCreator
	private let disposeBag = DisposeBag()
	
	private let panVariable: Variable<UIGestureRecognizerType?>
	private let rotateVariable: Variable<UIGestureRecognizerType?>
	
	init(timerCreator: ReactiveTimerCreator) {
		self.timerCreator = timerCreator
		panVariable = Variable(nil)
		rotateVariable = Variable(nil)
				
        
        // FYI 
        // Passing on the UIGesture at this point is dodgy as it's a reference 
        // It's state will change and render our filter useless. 
        // We therefore keep just the state in our observable buffers [.Began,.Began,.Ended]
        let rotateGesturesStartedEnded = rotateVariable.asObservable().filter { gesture in gesture?.state == .Began || gesture?.state == .Ended}.flatMap { (gesture) -> Observable<UIGestureRecognizerState> in
            return Observable.just(gesture!.state)
        }
        
        let panGesturesStartedEnded = panVariable.asObservable().filter { gesture in gesture?.state == .Began || gesture?.state == .Ended}.flatMap { (gesture) -> Observable<UIGestureRecognizerState> in
            return Observable.just(gesture!.state)
        }
        
        // Combine our latest .Began and .Ended from both Pan and Rotate.
        // If they are the same then return the same state. If not then return a Failed.
        let combineStartEndGestures = Observable.combineLatest(panGesturesStartedEnded, rotateGesturesStartedEnded) { (panState, rotateState) -> Observable<UIGestureRecognizerState> in
			
			// If only one is .Ended, the result is .Ended too
            var state = UIGestureRecognizerState.Ended
            if panState == .Began && rotateState == .Began {
                state = .Began
            }
            
            return Observable.just(state)
        }.switchLatest()
		
		// several .Began events in a row are to be treated the same as a single one, it has just meaning if a .Ended is in between
		let distinctCombineStartEndGestures = combineStartEndGestures.distinctUntilChanged()

        
        // condition: when both pan and rotate has begun
        let bothGesturesStarted = distinctCombineStartEndGestures.filter { (state) -> Bool in
            state == .Began
        }
        
        // condition: when one of pan or rotate has Ended
        let eitherGesturesEnded = distinctCombineStartEndGestures.filter { (state) -> Bool in
            state == .Ended
        }
        
		// when bothGesturesStarted, do this:
		bothGesturesStarted.subscribeNext { [unowned self] _ in
			
			self.delegate?.didStart()
			// create a timer that ticks every second
			let timer = self.timerCreator(interval: 1)
			// condition: but only three ticks
			let timerThatTicksThree = timer.take(4)
			// condition: and also, stop it immediately either pan or rotate ended
			let timerThatTicksThreeAndStops = timerThatTicksThree.takeUntil(eitherGesturesEnded)
			
			timerThatTicksThreeAndStops.subscribe(onNext: { [unowned self] count in
				// the imperative version waits for a second until didComplete is called, so we have to tick once more, but do not send the last tick to the delegate
				guard count < 4 else {
					return
					//do nothing
				}
				// when a tick happens, do this:
				self.delegate?.didTick(3 - count)
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