//
//  Observable+Extension.swift
//  RFP
//
//  Created by Mark Aron Szulyovszky on 19/01/2016.
//  Copyright © 2016 Mark Aron Szulyovszky. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
  
  class func timer(repeatEvery repeatEvery: Int) -> Observable<Int> {
    return Observable<Int>.timer(Double(repeatEvery), period: Double(repeatEvery), scheduler: MainScheduler.instance)
  }
  
  func subscribe(onNext onNext: (E -> Void)?, onCompleted: (() -> Void)?) {
    let _ = self.subscribe(onNext: onNext, onError: nil, onCompleted: onCompleted, onDisposed: nil)
  }
  
}