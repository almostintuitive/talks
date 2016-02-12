import XCTest
@testable import RFP


class RFPTests: XCTestCase {
	
	var sut: ImperativeGestureReactor!
	var mockDelegate: MockGestureReactorDelegate!
	var mockTimerCreatorCalled = 0
	weak var mockTimer: MockTimer?
    
    override func setUp() {
        super.setUp()
		let timerCreator: TimerCreator = { [unowned self] interval, repeats, onTick in
			self.mockTimerCreatorCalled += 1
			let mockTimer = MockTimer(interval: interval, repeats: repeats, onTick: onTick)
			self.mockTimer = mockTimer
			return mockTimer
		}
		sut = ImperativeGestureReactor(timerCreator: timerCreator)
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
		XCTAssertEqual(mockDelegate.tickCounts, [])
		XCTAssertEqual(mockTimerCreatorCalled, 0)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganPanGesture() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 0)
		XCTAssertEqual(mockDelegate.didTickCalled, 0)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [])
		XCTAssertEqual(mockTimerCreatorCalled, 0)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganPinchGesture() {
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 0)
		XCTAssertEqual(mockDelegate.didTickCalled, 0)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [])
		XCTAssertEqual(mockTimerCreatorCalled, 0)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganPanEndedPanBeganPinchGesture() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 0)
		XCTAssertEqual(mockDelegate.didTickCalled, 0)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [])
		XCTAssertEqual(mockTimerCreatorCalled, 0)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGestures() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 0)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndEndedPinch() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 0)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedOnce() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 1)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [0])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedOnceAndEndedPinch() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 1)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedTwice() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 2)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedThrice() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 3)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFrice() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 3)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndPanEnded() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 3)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedTwiceAndPanEndedAndPanBeganAgain() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 2)
		XCTAssertEqual(mockDelegate.didTickCalled, 2)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1])
		XCTAssertEqual(mockTimerCreatorCalled, 2)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndPanBeganAgain_ignoreAdditionalBegans() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 0)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
		XCTAssertEqual(mockDelegate.tickCounts, [])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndPanBeganAgain() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 1)
		XCTAssertEqual(mockDelegate.didTickCalled, 3)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 1)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndEndedPanGestureAndBeganPanAgain() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 2)
		XCTAssertEqual(mockDelegate.didTickCalled, 3)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 2)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndEndedPinchGestureAndBeganPinchAgain() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 2)
		XCTAssertEqual(mockDelegate.didTickCalled, 3)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 2)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgain() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 2)
		XCTAssertEqual(mockDelegate.didTickCalled, 3)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 2)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedOnce() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		
		XCTAssertEqual(mockDelegate.didStartCalled, 2)
		XCTAssertEqual(mockDelegate.didTickCalled, 4)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2, 0])
		XCTAssertEqual(mockTimerCreatorCalled, 2)
		XCTAssertNotNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFrice() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		
		XCTAssertEqual(mockDelegate.didStartCalled, 2)
		XCTAssertEqual(mockDelegate.didTickCalled, 6)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2, 0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 2)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFriceAndEndedBothGestures() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 2)
		XCTAssertEqual(mockDelegate.didTickCalled, 6)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2, 0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 2)
		XCTAssertNil(mockTimer)
	}
	
	func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFriceAndEndedBothGesturesAndStartedBothAgain() {
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		mockTimer!.mockExecuteOnTick()
		sut.handlePinch(MockPinchGestureRecognizer(state: .Ended))
		sut.handlePan(MockPanGestureRecognizer(state: .Ended))
		sut.handlePinch(MockPinchGestureRecognizer(state: .Began))
		sut.handlePan(MockPanGestureRecognizer(state: .Began))
		
		XCTAssertEqual(mockDelegate.didStartCalled, 3)
		XCTAssertEqual(mockDelegate.didTickCalled, 6)
		XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
		XCTAssertEqual(mockDelegate.tickCounts, [0, 1, 2, 0, 1, 2])
		XCTAssertEqual(mockTimerCreatorCalled, 3)
		XCTAssertNotNil(mockTimer)
	}
	
}
