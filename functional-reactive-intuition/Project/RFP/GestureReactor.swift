import Foundation
import UIKit


protocol GestureReactor: AnyObject {
	
	var delegate: GestureReactorDelegate? {get set}
	
	func handlePan(panGesture: UIPanGestureRecognizer)
	func handlePinch(pinchGesture: UIPinchGestureRecognizer)
	
}

protocol GestureReactorDelegate {
	
	func didStart()
	func didTick(count: Int)
	func didComplete()
	
}