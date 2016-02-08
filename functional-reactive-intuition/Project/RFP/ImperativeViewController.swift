//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ImperativeViewController: UIViewController, UIGestureRecognizerDelegate {

  var panPresent = false
  var pinchPresent = false
  var gestureTimer: NSTimer?
  var secondsLeft = 3
  
  @IBOutlet weak var draggableView: UIView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
    pan.delegate = self
    let pinch = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
    pinch.delegate = self
    self.draggableView.gestureRecognizers = [pan, pinch]
  }
  

  func handlePan(panGesture: UIPanGestureRecognizer) {

    //Handle our state
    if panGesture.state == .Began && self.panPresent == false {
      self.panPresent = true
      self.checkIfBothGesturesPresent()
    } else if panGesture.state == .Ended {
      self.panPresent = false
      self.stopTimerIfNeeded()
    }
    
    // Move the view
    let translation = panGesture.translationInView(self.view)
    panGesture.view!.center = CGPoint(x: panGesture.view!.center.x + translation.x, y: panGesture.view!.center.y + translation.y)
    panGesture.setTranslation(CGPointZero, inView: self.view)
    
  }
  
  func handleRotate(rotationGesture: UIRotationGestureRecognizer) {
    
    //Handle our state
    if rotationGesture.state == .Began && self.pinchPresent == false {
        self.pinchPresent = true
        self.checkIfBothGesturesPresent()
    } else if rotationGesture.state == .Ended {
        self.pinchPresent = false
        self.stopTimerIfNeeded()
    }
    
    // Move the view
    rotationGesture.view!.transform = CGAffineTransformRotate(rotationGesture.view!.transform,rotationGesture.rotation)
    rotationGesture.rotation = 0;
}
  
  func checkIfBothGesturesPresent() {
    if self.pinchPresent == true && self.panPresent == true && self.gestureTimer == nil {
      self.secondsLeft = 3
      self.gestureTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick:", userInfo: nil, repeats: true)
      print("started")
    }
  }
  
  func stopTimerIfNeeded() {
    if let gestureTimer = gestureTimer {
      gestureTimer.invalidate()
      self.gestureTimer = nil
      print("completed")
    }
  }
  
  func tick(timer: NSTimer) {
    if self.secondsLeft <= 0 {
      self.stopTimerIfNeeded()
      return
    }
    self.secondsLeft--
    print("tick")
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
    
}
