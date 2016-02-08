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

class ReactiveViewController: UIViewController, SetStatus {
    
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint! //For updating the position of the box when dragging
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        let rotate = UIRotationGestureRecognizer()
        rotate.delegate = self
        self.draggableView.gestureRecognizers = [pan, rotate]
        
        // condition: when pan has begun
        let panStarted = pan.rx_event.filter { gesture in gesture.state == .Began }
        // condition: when pan has ended
        let panEnded = pan.rx_event.filter { gesture in gesture.state == .Ended }
        
        // condition: when pinch has begun
        let rotateStarted = rotate.rx_event.filter { gesture in gesture.state == .Began }
        // condition: when pinch has ended
        let rotateEnded = rotate.rx_event.filter { gesture in gesture.state == .Ended }
        
        // condition: when both pan and pinch has begun
        let bothGesturesStarted = Observable.combineLatest(panStarted, rotateStarted) { (_, _) -> Bool in return true }
        
        // condition: when both pan and pinch ended
        let bothGesturesEnded = Observable.of(panEnded, rotateEnded).merge()
        
        
        // when bothGesturesStarted, do this:
        _ = bothGesturesStarted.subscribeNext { _ in
            
            self.setStatus("Started")
            // create a timer that ticks every second
            let timer = Observable<Int>.timer(repeatEvery: 1)
            // condition: but only three ticks
            let timerThatTicksThree = timer.take(3)
            // condition: and also, stop it immediately when both pan and pinch ended
            let timerThatTicksThreeAndStops = timerThatTicksThree.takeUntil(bothGesturesEnded)
            
            timerThatTicksThreeAndStops.subscribe(onNext: { count in
                // when a tick happens, do this:
                self.setStatus("Tick: \(count)")
                }, onCompleted: {
                    // when the timer completes, do this:
                    self.setStatus("Completed")
            })
        }
        
        /// 
        //
        // Extra Code to manipulate move and rotate the subview.
        
        // Recognise Any Pan to move our view
        let anyPan = pan.rx_event
        _ = anyPan.bindNext { (guesture) -> Void in
            let panGuesture = guesture as! UIPanGestureRecognizer
            // Move the view
            let translation = panGuesture.translationInView(self.view)
            self.centerXConstraint.constant += translation.x
            self.centerYConstraint.constant += translation.y
            panGuesture.setTranslation(CGPointZero, inView: self.view)
        }
        
        // Recognise Any Pan to move our view
        let anyRotate = rotate.rx_event
        _ = anyRotate.subscribeNext { (guesture) -> Void in
            let rotationGesture = guesture as! UIRotationGestureRecognizer
            // Move the view
            rotationGesture.view!.transform = CGAffineTransformRotate(rotationGesture.view!.transform,rotationGesture.rotation)
            rotationGesture.rotation = 0;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setStatus("Status: Waiting for Rotate & Pan")
    }
    
}

extension ReactiveViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
