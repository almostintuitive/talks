import Foundation
import RxSwift


typealias ReactiveTimerCreator = (interval: NSTimeInterval) -> Observable<Int>


class ReactiveTimerFactory {
	
	class func reactiveTimer(interval interval: NSTimeInterval) -> Observable<Int> {
		return Observable<Int>.timer(interval, period: interval, scheduler: MainScheduler.instance)
	}

}
