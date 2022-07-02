import Foundation
import Cocoa
import RxSwift
import RxCocoa
import Then

class ListPeopleViewController: NSViewController {
  @IBOutlet var tableView: NSTableView!
  @IBOutlet weak var messageView: NSTextField!

  private let bag = DisposeBag()
  fileprivate var viewModel: ListPeopleViewModel!
  fileprivate var navigator: Navigator!

  private var lastSelectedRow = -1

  static func createWith(navigator: Navigator, storyboard: NSStoryboard, viewModel: ListPeopleViewModel) -> ListPeopleViewController {
    return storyboard.instantiateViewController(ofType: ListPeopleViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bindUI()
  }

  func bindUI() {
    //show tweets in table view
    viewModel.people.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)

    //show message when no account available
  }

  @IBAction func tableViewDidSelectRow(sender: NSTableView) {
    if sender.selectedRow >= 0, sender.selectedRow != lastSelectedRow, let user = viewModel.people.value?[sender.selectedRow] {
      navigator.show(segue: .personTimeline(viewModel.account, username: user.username), sender: self)
      lastSelectedRow = sender.selectedRow
    } else {
      navigator.show(segue: .listTimeline(viewModel.account, viewModel.list), sender: self)
      sender.deselectAll(nil)
      lastSelectedRow = -1
    }
  }
}

extension ListPeopleViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return viewModel.people.value?.count ?? 0
  }
}

extension ListPeopleViewController: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let user = viewModel.people.value![row]
    return tableView.dequeueCell(ofType: UserCellView.self).then {cell in
      cell.update(with: user)
    }
  }
}
