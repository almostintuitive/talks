//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ImperativeViewController: UIViewController, UIGestureRecognizerDelegate, SetStatus, GestureReactorDelegate {
  
  private var gestureReactor: GestureReactor = ImperativeGestureReactor(timerCreator: { interval, repeats, onTick in Timer(interval: interval, repeats: repeats, onTick: onTick) })
  
  @IBOutlet weak var draggableView: UIView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var centerXConstraint: NSLayoutConstraint! //For updating the position of the box when dragging
  @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
    pan.delegate = self
    let rotate = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
    rotate.delegate = self
    self.draggableView.gestureRecognizers = [pan, rotate]
    gestureReactor.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.setStatus("Status: Waiting for Rotate & Pan")
  }
  
  @objc private func handlePan(panGesture: UIPanGestureRecognizer) {
    // Move the view
    let translation = panGesture.translationInView(self.view)
    self.centerXConstraint.constant += translation.x
    self.centerYConstraint.constant += translation.y
    
    panGesture.setTranslation(CGPointZero, inView: self.view)

    gestureReactor.handlePan(panGesture)
  }
  
  @objc private func handleRotate(rotationGesture: UIRotationGestureRecognizer) {
    // Move the view
    rotationGesture.view!.transform = CGAffineTransformRotate(rotationGesture.view!.transform,rotationGesture.rotation)
    rotationGesture.rotation = 0;

    gestureReactor.handleRotate(rotationGesture)
  }

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func didStart() {
    self.setStatus("Started")
  }
  
  func didTick(secondsLeft: Int) {
    self.setStatus("Tick: \(secondsLeft)")
  }
  
  func didComplete() {
    self.setStatus("Completed")
  }

}

protocol SetStatus {
  var statusLabel:UILabel! {get set}
  func setStatus(statusString:String)
}

extension SetStatus {
  func setStatus(statusString:String) {
    print(statusString)
    self.statusLabel.text = statusString
  }
}
