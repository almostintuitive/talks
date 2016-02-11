import Foundation


typealias TimerCreator = (interval: NSTimeInterval, repeats: Bool, onTick: TimerTicker) -> TimerType
typealias TimerTicker = (sender: TimerType) -> Void


protocol TimerType {
	
	func invalidate()
	
}

@objc class Timer: NSObject, TimerType {
	
	private var timer: NSTimer?
	private let onTick: TimerTicker
		
	init(interval: NSTimeInterval, repeats: Bool, onTick: TimerTicker) {
		self.onTick = onTick
		super.init()
		timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "tick", userInfo: nil, repeats: repeats)
	}
	
	func tick() {
		onTick(sender: self)
	}
	
	func invalidate() {
		timer?.invalidate()
	}

}