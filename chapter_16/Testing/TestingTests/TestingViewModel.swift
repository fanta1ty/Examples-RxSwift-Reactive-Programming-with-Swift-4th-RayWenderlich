import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Testing

class TestingViewModel : XCTestCase {
    var viewModel: ViewModel!
    var scheduler: ConcurrentDispatchQueueScheduler!
    
    override func setUp() {
        super.setUp()
        
        viewModel = ViewModel()
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    }
}

extension TestingViewModel {
    func testColorIsRedWhenHexStringIsFF0000_async() {
        let disposeBag = DisposeBag()
        
        let expect = expectation(description: #function)
        let expectedColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        var result: UIColor!
        
        viewModel.color.asObservable()
            .skip(1)
            .subscribe(onNext: {
                result = $0
                expect.fulfill()
            })
            .disposed(by: disposeBag)
        
        viewModel.hexString.accept("#ff0000")
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            XCTAssertEqual(expectedColor, result)
        }
    }
    
    func testColorIsRedWhenHexStringIsFF0000() throws {
        let colorObservable = viewModel.color.asObservable().subscribeOn(scheduler)
        
        viewModel.hexString.accept("#ff0000")
        
        XCTAssertEqual(try colorObservable.toBlocking(timeout: 1.0).first(), .red)
    }
    
    func testRgbIs010WhenHexStringIs00FF00() throws {
        let rgbObservable = viewModel.rgb.asObservable().subscribeOn(scheduler)
        
        viewModel.hexString.accept("#00ff00")
        let result = try rgbObservable.toBlocking().first()!
        
        XCTAssertEqual(0 * 255, result.0)
        XCTAssertEqual(1 * 255, result.1)
        XCTAssertEqual(0 * 255, result.2)
    }
    
    func testColorNameIsGreenWhenHexStringIs006636() throws {
        let colorNameObservable = viewModel.colorName.asObservable().subscribeOn(scheduler)
        
        viewModel.hexString.accept("#006636")
        
        XCTAssertEqual("rayWenderlichGreen", try colorNameObservable.toBlocking().first()!)
    }
}
