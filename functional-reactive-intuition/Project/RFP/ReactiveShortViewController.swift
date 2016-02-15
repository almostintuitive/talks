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

class ReactiveShortViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pan = UIPanGestureRecognizer()
    pan.delegate = self
    let pinch = UIPinchGestureRecognizer()
    pinch.delegate = self
    view.gestureRecognizers = [pan, pinch]

    let panStarted = pan.rx_event.filter { $0.state == .Began }
    let panEnded = pan.rx_event.filter { $0.state == .Ended }

    let pinchStarted = pinch.rx_event.filter { $0.state == .Began }
    let pinchEnded = pinch.rx_event.filter { $0.state == .Ended }

    // condition: when both pan and pinch ended
    let bothGesturesEnded = Observable.of(panEnded, pinchEnded).merge()

    // when both pan and pinch has begun, do this:
    let _ = Observable.zip(panStarted, pinchStarted) { (_, _) -> Bool in return true }.subscribeNext { _ in
      
      print("started")
      // create a timer that ticks every second, until 3 or until pan and pinch ended
      let timer = Observable<Int>.timer(repeatEvery: 1).take(3).takeUntil(bothGesturesEnded)

      timer.subscribe(onNext: { count in
        // when a tick happens, do this:
        print("tick: \(count)")
      }, onCompleted: {
        // when the timer completes, do this:
        print("completed")
      })
    }
  }
  
}

extension ReactiveShortViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}
