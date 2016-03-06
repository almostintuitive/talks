//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReactiveViewController: UIViewController, SetStatus, GestureReactorDelegate {
  
  @IBOutlet weak var draggableView: UIView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var centerXConstraint: NSLayoutConstraint! //For updating the position of the box when dragging
  @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
  
  private var gestureReactor: GestureReactor!
  
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
    pan.delegate = self
    let rotate = UIRotationGestureRecognizer(target: self, action: "handleRotate:")
    rotate.delegate = self
    draggableView.gestureRecognizers = [pan, rotate]
    
    gestureReactor = ReactiveGestureReactor(timerCreator: { interval in ReactiveTimerFactory.reactiveTimer(interval: interval) }, gestureRecognizers: (pan, rotate))
    gestureReactor.delegate = self

    
    ///
    ///
    /// Extra Code to manipulate move and rotate the subview.
    ///
    /// Uses custom infix on CGPoint to '-' or '+' two together.
    
    let panLocation = pan.rx_event.map { [unowned self] in $0.locationInView(self.view) - self.view.center }
    panLocation.map { $0.x }
      .bindTo(self.centerXConstraint.rx_constant)
      .addDisposableTo(self.disposeBag)
    
    panLocation.map { $0.y }
      .bindTo(self.centerYConstraint.rx_constant)
      .addDisposableTo(self.disposeBag)
    
    rotate.rx_event
      .map { ($0 as! UIRotationGestureRecognizer).rotation }
      .bindTo(self.draggableView.rx_rotate)
      .addDisposableTo(self.disposeBag)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.setStatus("Status: Waiting for Rotate & Pan")
  }
  
  @objc private func handlePan(panGesture: UIPanGestureRecognizer) {
    gestureReactor.handlePan(panGesture)
  }
  
  @objc private func handleRotate(rotationGesture: UIRotationGestureRecognizer) {
    gestureReactor.handleRotate(rotationGesture)
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

extension ReactiveViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
