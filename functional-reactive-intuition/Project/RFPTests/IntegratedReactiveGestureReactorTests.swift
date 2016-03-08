import XCTest
import RxSwift
import RxCocoa
@testable import RFP


class IntegratedReactiveGestureReactorTests: XCTestCase {

    var sut: IntegratedReactiveGestureReactor!
    var mockDelegate: MockGestureReactorDelegate!
    var mockPanGestureObservable: Observable<UIGestureRecognizerType>!
    var mockRotateGestureObservable: Observable<UIGestureRecognizerType>!
    var mockPanVariable: Variable<UIGestureRecognizerType>!
    var mockRotateVariable: Variable<UIGestureRecognizerType>!
    var mockTimerCreatorCalled = 0
    // FIXME cannot be weak, so we cannot test the same way as in ImperativeGestureReactorTests
    var mockTimer: MockReactiveTimer?
    
    override func setUp() {
        super.setUp()
        mockPanVariable = Variable(MockPanGestureRecognizer(state: .Possible))
        mockRotateVariable = Variable(MockRotateGestureRecognizer(state: .Possible))
        mockPanGestureObservable = mockPanVariable.asObservable().skip(1)
        mockRotateGestureObservable = mockRotateVariable.asObservable().skip(1)
        let timerCreator: ReactiveTimerCreator = { [unowned self] interval in
            self.mockTimerCreatorCalled += 1
            let mockTimer = MockReactiveTimer(interval: interval)
            self.mockTimer = mockTimer
            return mockTimer.asObservable().skip(1)
        }
        sut = IntegratedReactiveGestureReactor(timerCreator: timerCreator, panGestureObservable: mockPanGestureObservable, rotateGestureObservable: mockRotateGestureObservable)
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
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 0)
        XCTAssertEqual(mockDelegate.didTickCalled, 0)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
        XCTAssertEqual(mockTimerCreatorCalled, 0)
        XCTAssertNil(mockTimer)
    }
    
    func testBeganRotateGesture() {
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 0)
        XCTAssertEqual(mockDelegate.didTickCalled, 0)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
        XCTAssertEqual(mockTimerCreatorCalled, 0)
        XCTAssertNil(mockTimer)
    }
    
    func testBeganPanEndedPanBeganRotateGesture() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 0)
        XCTAssertEqual(mockDelegate.didTickCalled, 0)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
        XCTAssertEqual(mockTimerCreatorCalled, 0)
        XCTAssertNil(mockTimer)
    }
    
    func testBeganBothGestures() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 1)
        XCTAssertEqual(mockDelegate.didTickCalled, 0)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
        XCTAssertEqual(mockTimerCreatorCalled, 1)
        XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndEndedRotate() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 1)
        XCTAssertEqual(mockDelegate.didTickCalled, 0)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
        XCTAssertEqual(mockTimerCreatorCalled, 1)
        //    XCTAssertNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedOnce() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        
        XCTAssertEqual(mockDelegate.didStartCalled, 1)
        XCTAssertEqual(mockDelegate.didTickCalled, 1)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2])
        XCTAssertEqual(mockTimerCreatorCalled, 1)
        //    XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedOnceAndEndedRotate() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 1)
        XCTAssertEqual(mockDelegate.didTickCalled, 1)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2])
        XCTAssertEqual(mockTimerCreatorCalled, 1)
        //    XCTAssertNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedTwice() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
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
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
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
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
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
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 1)
        XCTAssertEqual(mockDelegate.didTickCalled, 3)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
        XCTAssertEqual(mockTimerCreatorCalled, 1)
        //    XCTAssertNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedTwiceAndPanEndedAndPanBeganAgain() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 2)
        XCTAssertEqual(mockDelegate.didTickCalled, 2)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1])
        XCTAssertEqual(mockTimerCreatorCalled, 2)
        //    XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndPanBeganAgain_ignoreAdditionalBegans() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 1)
        XCTAssertEqual(mockDelegate.didTickCalled, 0)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 0)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [])
        XCTAssertEqual(mockTimerCreatorCalled, 1)
        //    XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedFriceAndPanBeganAgain() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 1)
        XCTAssertEqual(mockDelegate.didTickCalled, 3)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
        XCTAssertEqual(mockTimerCreatorCalled, 1)
        //    XCTAssertNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedFriceAndEndedPanGestureAndBeganPanAgain() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 2)
        XCTAssertEqual(mockDelegate.didTickCalled, 3)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
        XCTAssertEqual(mockTimerCreatorCalled, 2)
        //    XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedFriceAndEndedRotateGestureAndBeganRotateAgain() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 2)
        XCTAssertEqual(mockDelegate.didTickCalled, 3)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
        XCTAssertEqual(mockTimerCreatorCalled, 2)
        //    XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgain() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 2)
        XCTAssertEqual(mockDelegate.didTickCalled, 3)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0])
        XCTAssertEqual(mockTimerCreatorCalled, 2)
        //    XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedOnce() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        
        XCTAssertEqual(mockDelegate.didStartCalled, 2)
        XCTAssertEqual(mockDelegate.didTickCalled, 4)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 1)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0, 2])
        XCTAssertEqual(mockTimerCreatorCalled, 2)
        //    XCTAssertNotNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFrice() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
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
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 2)
        XCTAssertEqual(mockDelegate.didTickCalled, 6)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0, 2, 1, 0])
        XCTAssertEqual(mockTimerCreatorCalled, 2)
        //    XCTAssertNil(mockTimer)
    }
    
    func testBeganBothGesturesAndTickedFriceAndEndedBothGesturesAndBeganBothAgainAndTickedFriceAndEndedBothGesturesAndStartedBothAgain() {
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockTimer!.mockExecuteOnTick()
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Ended)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Ended)
        mockRotateVariable.value = MockRotateGestureRecognizer(state: .Began)
        mockPanVariable.value = MockPanGestureRecognizer(state: .Began)
        
        XCTAssertEqual(mockDelegate.didStartCalled, 3)
        XCTAssertEqual(mockDelegate.didTickCalled, 6)
        XCTAssertEqual(mockDelegate.didCompleteCalled, 2)
        XCTAssertEqual(mockDelegate.tickSecondsLefts, [2, 1, 0, 2, 1, 0])
        XCTAssertEqual(mockTimerCreatorCalled, 3)
        //    XCTAssertNotNil(mockTimer)
    }

}
