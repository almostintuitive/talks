import Foundation
import UIKit


protocol UIGestureRecognizerType {
	
	var state: UIGestureRecognizerState { get }
	
}

protocol UIPanGestureRecognizerType: UIGestureRecognizerType {
	
}

protocol UIPinchGestureRecognizerType: UIGestureRecognizerType {
	
}

extension UIGestureRecognizer: UIGestureRecognizerType {
	
}

extension UIPanGestureRecognizer: UIPanGestureRecognizerType {
	
}

extension UIPinchGestureRecognizer: UIPinchGestureRecognizerType {
	
}