//
//  ViewController.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 11/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import UIKit

class ImperativeViewController: UIViewController, UIGestureRecognizerDelegate, SetStatus {
    
    var panPresent = false
    var pinchPresent = false
    var gestureTimer: NSTimer?
    var secondsLeft = 3
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setStatus("Status: Waiting for Rotate & Pan")
    }
    
    func handlePan(panGuesture: UIPanGestureRecognizer) {
        
        // Move the view
        let translation = panGuesture.translationInView(self.view)
        self.centerXConstraint.constant += translation.x
        self.centerYConstraint.constant += translation.y
        
        panGuesture.setTranslation(CGPointZero, inView: self.view)
        
        //Handle our state
        if panGuesture.state == .Began && self.panPresent == false {
            self.panPresent = true
            self.checkIfBothGesturesPresent()
        } else if panGuesture.state == .Ended {
            self.panPresent = false
            self.stopTimerIfNeeded()
        }
    }
    
    func handleRotate(rotationGesture: UIRotationGestureRecognizer) {
        
        // Move the view
        rotationGesture.view!.transform = CGAffineTransformRotate(rotationGesture.view!.transform,rotationGesture.rotation)
        rotationGesture.rotation = 0;
        
        //Handle our state
        if rotationGesture.state == .Began && self.pinchPresent == false {
            self.pinchPresent = true
            self.checkIfBothGesturesPresent()
        } else if rotationGesture.state == .Ended {
            self.pinchPresent = false
            self.stopTimerIfNeeded()
        }
    }
    
    func checkIfBothGesturesPresent() {
        if self.pinchPresent == true && self.panPresent == true && self.gestureTimer == nil {
            self.secondsLeft = 3
            self.gestureTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick:", userInfo: nil, repeats: true)
            self.setStatus("Started")
        }
    }
    
    func stopTimerIfNeeded() {
        if let gestureTimer = gestureTimer {
            gestureTimer.invalidate()
            self.gestureTimer = nil
            self.setStatus("Completed")
        }
    }
    
    func tick(timer: NSTimer) {
        if self.secondsLeft <= 0 {
            self.stopTimerIfNeeded()
            return
        }
        self.secondsLeft--
        self.setStatus("Tick: \(self.secondsLeft)")
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
