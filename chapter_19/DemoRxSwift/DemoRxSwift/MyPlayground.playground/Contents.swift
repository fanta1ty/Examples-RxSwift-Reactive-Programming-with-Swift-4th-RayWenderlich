import UIKit
import RxSwift
import RxSwiftExt

_ = Observable.of("a", "b", "a", "c", "b", "a", "d")
    .distinct()
    .toArray()
    .subscribe(onSuccess: { print($0) })

struct Person {
    let name: String
}

Observable
    .of(Person(name: "Bart"), Person(name: "Lisa"), Person(name: "Maggie"))
    .mapAt(\.name)
    .subscribe(onNext: { print($0) })

let (evens, odds) = Observable
    .of(1, 2, 3, 5, 6, 7, 8)
    .partition { $0 % 2 == 0 }

_ = evens.debug("evens").subscribe()
_ = odds.debug("odds").subscribe()

_ = Observable.of(
    [1, 3, 5],
    [2, 4])
.mapMany({ pow(2, $0) })
.debug("power of 2")
.subscribe()
