import UIKit
import RxSwift
import RxCocoa


// Start coding here
let elementsPerSecond = 1
let maxElements = 58
let replayedElements = 1
let replayDelay: TimeInterval = 3

let sourceObservable = Observable<Int>
    .interval(.milliseconds(Int(1000.0 / Double(elementsPerSecond))), scheduler: MainScheduler.instance)
    .replay(replayedElements)

// Support code -- DO NOT REMOVE
class TimelineView<E>: TimelineViewBase, ObserverType where E: CustomStringConvertible {
  static func make() -> TimelineView<E> {
    return TimelineView(width: 400, height: 100)
  }
  public func on(_ event: Event<E>) {
    switch event {
    case .next(let value):
      add(.next(String(describing: value)))
    case .completed:
      add(.completed())
    case .error(_):
      add(.error())
    }
  }
}

let sourceTimeline = TimelineView<Int>.make()
let replayedTimeline = TimelineView<Int>.make()

_ = sourceObservable.subscribe(sourceTimeline)

DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
 _ = sourceObservable.subscribe(replayedTimeline)
}

let stack = UIStackView.makeVertical([
    UILabel.makeTitle("replay"),
    UILabel.make("Emit \(elementsPerSecond) per second:"),
    sourceTimeline,
    UILabel.make("Replay \(replayedElements) after \(replayDelay) sec:"),
    replayedTimeline
])

_ = sourceObservable.connect()
let hostView = setupHostView()
hostView.addSubview(stack)
hostView
