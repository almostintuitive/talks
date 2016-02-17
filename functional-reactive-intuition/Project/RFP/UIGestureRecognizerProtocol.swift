import Foundation
import UIKit


protocol UIGestureRecognizerType {
	
	var state: UIGestureRecognizerState { get }
	
}

protocol UIPanGestureRecognizerType: UIGestureRecognizerType {
	
}

protocol UIRotationGestureRecognizerType: UIGestureRecognizerType {
	
}

extension UIGestureRecognizer: UIGestureRecognizerType {
	
}

extension UIPanGestureRecognizer: UIPanGestureRecognizerType {
	
}

extension UIRotationGestureRecognizer: UIRotationGestureRecognizerType {
	
}