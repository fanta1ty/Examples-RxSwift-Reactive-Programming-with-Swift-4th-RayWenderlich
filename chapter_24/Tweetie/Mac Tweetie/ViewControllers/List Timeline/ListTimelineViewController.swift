import Foundation
import Cocoa
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import Then

class ListTimelineViewController: NSViewController {
  private let bag = DisposeBag()
  fileprivate var viewModel: ListTimelineViewModel!
  fileprivate var navigator: Navigator!

  @IBOutlet var tableView: NSTableView!

  static func createWith(navigator: Navigator, storyboard: NSStoryboard, viewModel: ListTimelineViewModel) -> ListTimelineViewController {
    return storyboard.instantiateViewController(ofType: ListTimelineViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bindUI()
  }

  func bindUI() {
    // Show tweets in table view
  }
}
