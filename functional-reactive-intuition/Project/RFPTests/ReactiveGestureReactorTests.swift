import XCTest
import RxSwift
@testable import RFP


class ReactiveGestureReactorTests: XCTestCase {

	var sut: ReactiveGestureReactor!
	var mockDelegate: MockGestureReactorDelegate!
	var mockTimerCreatorCalled = 0
	// FIXME cannot be weak, so we cannot test the same way as in ImperativeGestureReactorTests
	var mockTimer: MockReactiveTimer?

	override func setUp() {
        super.setUp()
		let timerCreator: ReactiveTimerCreator = { [unowned self] interval in
			self.mockTimerCreatorCalled += 1
			let mockTimer = MockReactiveTimer(interval: interval)
			self.mockTimer = mockTimer
			return mockTimer.asObservable().skip(1)
		}
		sut = ReactiveGestureReactor(timerCreator: timerCreator)
		mockDelegate = MockGestureReactorDelegate()
		sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

  func testDoNothing() {
    XCTAssertNil(mockTimer)
    XCTAssertEqual(mockDelegate.didStartCalled, 0)
    XCTAssertEqual(mockDelegate.didTickCalled, 0)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
    XCTAssertEqual(mockTimerCreatorCalled, 0)
    XCTAssertNil(mockTimer)
  }
  
  func testBeganPanGesture() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 0)
    XCTAssertEqual(mockDelegate.didTickCalled, 0)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
    XCTAssertEqual(mockTimerCreatorCalled, 0)
    XCTAssertNil(mockTimer)
  }
  
  func testBeganRotateGesture() {
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 0)
    XCTAssertEqual(mockDelegate.didTickCalled, 0)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
    XCTAssertEqual(mockTimerCreatorCalled, 0)
    XCTAssertNil(mockTimer)
  }
  
  func testBeganPanEndedPanBeganRotateGesture() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 0)
    XCTAssertEqual(mockDelegate.didTickCalled, 0)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
    XCTAssertEqual(mockTimerCreatorCalled, 0)
    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGestures() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 0)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndEndedRotate() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 0)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedOnce() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 1)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedOnceAndEndedRotate() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 1)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedTwice() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 2)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedThrice() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 3)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFrice() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 3)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndPanEnded() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 3)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedTwiceAndPanEndedAndPanBeganAgain() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 2)
    XCTAssertEqual(mockDelegate.didTickCalled, 2)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1])
    XCTAssertEqual(mockTimerCreatorCalled, 2)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndPanBeganAgain_ignoreAdditionalBegans() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 0)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndPanBeganAgain() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 1)
    XCTAssertEqual(mockDelegate.didTickCalled, 3)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 1)
//    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndEndedPanGestureAndBeganPanAgain() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 2)
    XCTAssertEqual(mockDelegate.didTickCalled, 3)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 2)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndEndedRotateGestureAndBeganRotateAgain() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 2)
    XCTAssertEqual(mockDelegate.didTickCalled, 3)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 2)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgain() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 2)
    XCTAssertEqual(mockDelegate.didTickCalled, 3)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 2)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedOnce() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    
    XCTAssertEqual(mockDelegate.didStartCalled, 2)
    XCTAssertEqual(mockDelegate.didTickCalled, 4)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0, 2])
    XCTAssertEqual(mockTimerCreatorCalled, 2)
//    XCTAssertNotNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFrice() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    
    XCTAssertEqual(mockDelegate.didStartCalled, 2)
    XCTAssertEqual(mockDelegate.didTickCalled, 6)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0, 2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 2)
//    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFriceAndEndedBothGestures() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 2)
    XCTAssertEqual(mockDelegate.didTickCalled, 6)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0, 2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 2)
//    XCTAssertNil(mockTimer)
  }
  
  func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFriceAndEndedBothGesturesAndStartedBothAgain() {
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    mockTimer!.mockExecuteOnTick()
    sut.handleRotate(MockRotateGestureRecognizer(state: .Ended))
    sut.handlePan(MockPanGestureRecognizer(state: .Ended))
    sut.handleRotate(MockRotateGestureRecognizer(state: .Began))
    sut.handlePan(MockPanGestureRecognizer(state: .Began))
    
    XCTAssertEqual(mockDelegate.didStartCalled, 3)
    XCTAssertEqual(mockDelegate.didTickCalled, 6)
    XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
    XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0, 2, 1, 0])
    XCTAssertEqual(mockTimerCreatorCalled, 3)
//    XCTAssertNotNil(mockTimer)
  }

}
