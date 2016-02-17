import Foundation
import UIKit


protocol GestureReactor {
	
	var delegate: GestureReactorDelegate? {get set}
	
	func handlePan(panGesture: UIPanGestureRecognizerType)
	func handleRotate(rotateGesture: UIRotationGestureRecognizerType)
	
}

protocol GestureReactorDelegate {
	
	func didStart()
	func didTick(secondsLeft: Int)
	func didComplete()
	
}