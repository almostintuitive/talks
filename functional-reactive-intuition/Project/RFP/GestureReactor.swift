import Foundation
import UIKit


protocol GestureReactor {
	
	var delegate: GestureReactorDelegate? {get set}
	
	func handlePan(panGesture: UIPanGestureRecognizerType)
	func handlePinch(pinchGesture: UIPinchGestureRecognizerType)
	
}

protocol GestureReactorDelegate {
	
	func didStart()
	func didTick(count: Int)
	func didComplete()
	
}