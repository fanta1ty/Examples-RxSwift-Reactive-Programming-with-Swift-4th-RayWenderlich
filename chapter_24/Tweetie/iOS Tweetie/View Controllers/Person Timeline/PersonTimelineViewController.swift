import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then

class PersonTimelineViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  private let bag = DisposeBag()
  private var viewModel: PersonTimelineViewModel!
  private var navigator: Navigator!

  typealias TweetSection = AnimatableSectionModel<String, Tweet>

  static func createWith(navigator: Navigator, storyboard: UIStoryboard, viewModel: PersonTimelineViewModel) -> PersonTimelineViewController {
    return storyboard.instantiateViewController(ofType: PersonTimelineViewController.self).then { vc in
      vc.navigator = navigator
      vc.viewModel = viewModel
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 90
    tableView.rowHeight = UITableView.automaticDimension
    title = "Loading..."
    bindUI()
  }

  func bindUI() {
    //bind the title

    //bind the tweets to the table view
    
  }

  private func createTweetsDataSource() -> RxTableViewSectionedAnimatedDataSource<TweetSection> {
    let dataSource = RxTableViewSectionedAnimatedDataSource<TweetSection>(configureCell: { dataSource, tableView, indexPath, tweet in
      return tableView.dequeueCell(ofType: TweetCellView.self).then { cell in
        cell.update(with: tweet)
      }
    })
    dataSource.titleForHeaderInSection = { (ds, section: Int) -> String in
      return ds[section].model
    }
    return dataSource
  }
}
