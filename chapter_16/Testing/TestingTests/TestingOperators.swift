import XCTest
import RxSwift
import RxTest
import RxBlocking

class TestingOperators : XCTestCase {
    var scheduler: TestScheduler!
    var subscription: Disposable!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        scheduler.scheduleAt(1000) {
            self.subscription.dispose()
        }
        
        scheduler = nil
        super.tearDown()
    }
}

extension TestingOperators {
    func testAmb() {
        let observer = scheduler.createObserver(String.self)
        
        let observableA = scheduler.createHotObservable([
            .next(100, "a"),
            .next(200, "b"),
            .next(300, "c")
        ])
        
        let observableB = scheduler.createHotObservable([
            .next(90, "1"),
            .next(200, "2"),
            .next(300, "3")
        ])
        
        let ambObservable = observableA.amb(observableB)
        
        self.subscription = ambObservable.subscribe(observer)
        scheduler.start()
        
        let results = observer.events.compactMap { $0.value.element }
        XCTAssertEqual(results, ["1", "2", "3"])
    }
    
    func testFilter() {
        let observer = scheduler.createObserver(Int.self)
        
        let observable = scheduler.createHotObservable([
            .next(100, 1),
            .next(200, 2),
            .next(300, 3),
            .next(400, 2),
            .next(500, 1)
        ])
        
        let filterObservable = observable.filter { $0 < 3 }
        
        scheduler.scheduleAt(0) {
            self.subscription = filterObservable.subscribe(observer)
        }
        
        scheduler.start()
        
        let results = observer.events.compactMap { $0.value.element }
        
        XCTAssertEqual(results, [1, 2, 2, 1])
    }
    
    func testToArray() throws {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        let toArrayObservable = Observable.of(1, 2).subscribeOn(scheduler)
        
        XCTAssertEqual(try toArrayObservable.toBlocking().toArray(), [1, 2])
    }
    
    func testToArrayMaterialized() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let toArrayObservable = Observable.of(1, 2).subscribeOn(scheduler)
        
        let result = toArrayObservable
            .toBlocking()
            .materialize()
        
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements, [1, 2])
            
        case .failed(_, let error):
            XCTFail(error.localizedDescription)
        }
    }
}
