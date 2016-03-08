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

class IntegratedReactiveViewController: UIViewController, SetStatus, GestureReactorDelegate {
    
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var centerXConstraint: NSLayoutConstraint! //For updating the position of the box when dragging
    @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
    
    private let pan: UIPanGestureRecognizer
    private let rotate: UIRotationGestureRecognizer
    private var gestureReactor: IntegratedReactiveGestureReactor
    
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        pan = UIPanGestureRecognizer()
        rotate = UIRotationGestureRecognizer()
        gestureReactor = IntegratedReactiveGestureReactor(timerCreator: { interval in ReactiveTimerFactory.reactiveTimer(interval: interval) }, panGestureEvent: pan.rx_event, rotateGestureEvent: rotate.rx_event)

        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        pan = UIPanGestureRecognizer()
        rotate = UIRotationGestureRecognizer()
        gestureReactor = IntegratedReactiveGestureReactor(timerCreator: { interval in ReactiveTimerFactory.reactiveTimer(interval: interval) }, panGestureEvent: pan.rx_event, rotateGestureEvent: rotate.rx_event)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gestureReactor.delegate = self
        
        self.draggableView.gestureRecognizers = [pan, rotate]
        
        
        ///
        ///
        /// Extra Code to manipulate move and rotate the subview.
        ///
        /// Uses custom infix on CGPoint to '-' or '+' two together.
        
        let panLocation = pan.rx_event.map { [unowned self] in
            $0.locationInView(self.view) - self.view.center
        }
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

extension IntegratedReactiveViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
