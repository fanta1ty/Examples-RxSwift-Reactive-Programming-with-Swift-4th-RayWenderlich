import UIKit
import RxSwift
import RxCocoa

enum MyError: Error {
    case anError
}

example(of: "just, of, from") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable<Int>.just(one)
    observable.subscribe(onNext: { a in
        print("observable: \(a)\n")
    }).dispose()
    
    let observable2 = Observable.of(one, two, three)
    observable2.subscribe(onNext: { a in
        print("observable2: \(a)\n")
    }).dispose()
    
    let observable3 = Observable.of([one, two, three])
    observable3.subscribe(onNext: { a in
        print("observable3: \(a)\n")
    }).dispose()
    
    let observable4 = Observable.from([one, two, three])
    observable4.subscribe(onNext: { a in
        print("observable4: \(a)\n")
    }).dispose()
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    observable.subscribe { event in
        print("\(event)\n")
    }
    
    observable.subscribe { event in
        if let element = event.element {
            print("\(element)\n")
        }
    }
    
    observable.subscribe(onNext: { element in
        print("\(element)\n")
    })
}

example(of: "empty") {
    let observable = Observable<Void>.empty()
    observable.subscribe(onNext: { element in
        print(element)
    }, onCompleted: {
        print("Completed")
    })
}

example(of: "never") {
    let observable = Observable<Void>.never()
    
    observable.subscribe(onNext: { element in
        print(element)
    }, onCompleted: {
        print("Completed")
    })
}

example(of: "range") {
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable.subscribe(onNext: { i in
        let n = Double(i)
        let fibonacci = Int(
            ((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded()
        )
        
        print("Fibonacci: \(fibonacci)")
    })
}

example(of: "dispose") {
    let observable = Observable.of("A", "B", "C")
    let subscription = observable.subscribe { event in
        print(event)
    }
    subscription.dispose()
}

example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C")
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
}

example(of: "create") {
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        observer.onNext("1")
        //observer.onError(MyError.anError)
        observer.onCompleted()
        observer.onNext("?")
        
        return Disposables.create()
    }.subscribe(onNext: {
        print($0)
    }, onError: {
        print($0)
    }, onCompleted: {
        print("Completed")
    }, onDisposed: {
        print("Disposed")
    })
    //.disposed(by: disposeBag)
}

example(of: "deferred") {
    let disposeBag = DisposeBag()
    
    var flip = false
    
    let factory: Observable<Int> = Observable.deferred {
        flip.toggle()
        
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
        .disposed(by: disposeBag)
        print()
    }
}

example(of: "Single") {
    let disposeBag = DisposeBag()
    
    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    func loadText(from name: String) -> Single<String> {
        return Single.create { single in
            let disposable = Disposables.create()
            
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.failure(FileReadError.fileNotFound))
                return disposable
            }
            
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.failure(FileReadError.unreadable))
                return disposable
            }
            
            guard let contents = String(data: data, encoding: .utf8) else {
                single(.failure(FileReadError.encodingFailed))
                return disposable
            }
            
            single(.success(contents))
            return disposable
        }
    }
    
    loadText(from: "Copyright")
        .subscribe {
            switch $0 {
            case .success(let string):
                print(string)
                
            case .failure(let error):
                print(error)
            }
        }
        .disposed(by: disposeBag)
}
