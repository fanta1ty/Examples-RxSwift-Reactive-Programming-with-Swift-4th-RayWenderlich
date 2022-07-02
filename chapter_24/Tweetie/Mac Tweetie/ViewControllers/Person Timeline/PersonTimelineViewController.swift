import Foundation
import Cocoa
import RxSwift
import RxCocoa
import Then

class PersonTimelineViewController: NSViewController {

  @IBOutlet var tableView: NSTableView!

  private let bag = DisposeBag()
  fileprivate var viewModel: PersonTimelineViewModel!
  fileprivate var navigator: Navigator!

  fileprivate var tweets = [Tweet]()

  static func createWith(navigator: Navigator, storyboard: NSStoryboard, viewModel: PersonTimelineViewModel) -> PersonTimelineViewController {
    return storyboard.instantiateViewController(ofType: PersonTimelineViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    NSApp.windows.first?.title = "Loading timeline..."
    bindUI()
  }

  func bindUI() {
    //bind the window title

    //reload the table when tweets come in
  }
}

extension PersonTimelineViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return tweets.count
  }
}

extension PersonTimelineViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let tweet = tweets[row]
    return tableView.dequeueCell(ofType: TweetCellView.self).then { cell in
      cell.update(with: tweet)
    }
  }
}
