import Foundation
import UIKit


protocol GestureReactor: AnyObject {
	
	func handlePan(panGesture: UIPanGestureRecognizer)
	func handlePinch(pinchGesture: UIPinchGestureRecognizer)
	
}