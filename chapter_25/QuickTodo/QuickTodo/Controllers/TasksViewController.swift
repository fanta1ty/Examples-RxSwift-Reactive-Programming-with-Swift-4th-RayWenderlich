import UIKit
import RxSwift
import RxDataSources
import Action
import NSObject_Rx

class TasksViewController: UIViewController, BindableType {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var statisticsLabel: UILabel!
  @IBOutlet var newTaskButton: UIBarButtonItem!
  
  var viewModel: TasksViewModel!
  var dataSource: RxTableViewSectionedAnimatedDataSource<TaskSection>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 60
    
    configureDataSource()
    
    setEditing(true, animated: false)
  }
  
  func bindViewModel() {
    viewModel.sectionedItems
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: self.rx.disposeBag)
    
    newTaskButton.rx.action = viewModel.onCreateTask()
    
    tableView.rx.itemSelected
      .do(onNext: { [unowned self] indexPath in
        self.tableView.deselectRow(at: indexPath, animated: false)
      })
      .map { [unowned self] indexPath in
        try! self.dataSource.model(at: indexPath) as! TaskItem
      }
      .bind(to: viewModel.editAction.inputs)
      .disposed(by: self.rx.disposeBag)
    
    tableView.rx.itemDeleted
      .map { [unowned self] indexPath in
        try! self.tableView.rx.model(at: indexPath)
      }
      .bind(to: viewModel.deleteAction.inputs)
      .disposed(by: self.rx.disposeBag)
  }
}

extension TasksViewController {
  private func configureDataSource() {
    dataSource = RxTableViewSectionedAnimatedDataSource<TaskSection>(configureCell: { [weak self] dataSource, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCell(withIdentifier: "TaskItemCell", for: indexPath) as! TaskItemTableViewCell
      
      if let self = self {
        cell.configure(with: item, action: self.viewModel.onToggle(task: item))
      }
      
      return cell
    }, titleForHeaderInSection: { dataSource, index in
      dataSource.sectionModels[index].model
    }, canEditRowAtIndexPath: { _, _ in true })
  }
}
