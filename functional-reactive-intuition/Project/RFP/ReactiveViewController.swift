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

class ReactiveViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pan = UIPanGestureRecognizer()
    pan.delegate = self
    let pinch = UIPinchGestureRecognizer()
    pinch.delegate = self
    view.gestureRecognizers = [pan, pinch]
    
    // condition: when pan has begun
    let panStarted = pan.rx_event.filter { gesture in gesture.state == .Began }
    // condition: when pan has ended
    let panEnded = pan.rx_event.filter { gesture in gesture.state == .Ended }
    
    // condition: when pinch has begun
    let pinchStarted = pinch.rx_event.filter { gesture in gesture.state == .Began }
    // condition: when pinch has ended
    let pinchEnded = pinch.rx_event.filter { gesture in gesture.state == .Ended }
    
    // condition: when both pan and pinch has begun
    let bothGesturesStarted = Observable.of(panStarted, pinchStarted).merge(maxConcurrent: 1)
    // condition: when both pan and pinch ended
    let bothGesturesEnded = Observable.of(panEnded, pinchEnded).merge()
    

    // when bothGesturesStarted, do this:
    bothGesturesStarted.subscribeNext { _ in
      
      print("started")
      // create a timer that ticks every second
      let timer = Observable<Int>.timer(repeatEvery: 1)
      // condition: but only three ticks
      let timerThatTicksThree = timer.take(3)
      // condition: and also, stop it immediately when both pan and pinch ended
      let timerThatTicksThreeAndStops = timerThatTicksThree.takeUntil(bothGesturesEnded)
      
      timerThatTicksThreeAndStops.subscribe(onNext: { count in
        // when a tick happens, do this:
        print("tick: \(count)")
      }, onCompleted: {
        // when the timer completes, do this:
        print("completed")
      })
    }
  }
  
}

extension ReactiveViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
