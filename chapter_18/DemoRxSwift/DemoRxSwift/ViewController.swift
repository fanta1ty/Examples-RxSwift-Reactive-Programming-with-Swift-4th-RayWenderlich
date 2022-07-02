//
//  ViewController.swift
//  DemoRxSwift
//
//  Created by User on 25/05/2022.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    enum MyModel {
        case text(String)
        case pairOfImages(UIImage, UIImage)
    }
    
    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    
    private let observable = Observable<[MyModel]>.just([
        .text("Paris"),
        .pairOfImages(UIImage(named: "001.jpeg")!, UIImage(named: "002.jpeg")!),
        .text("London"),
        .pairOfImages(UIImage(named: "003.jpeg")!, UIImage(named: "004.jpeg")!)
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "TextCell", bundle: .main), forCellReuseIdentifier: "TextCell")
        tableView.register(UINib(nibName: "ImagesCell", bundle: .main), forCellReuseIdentifier: "ImagesCell")
        
        bindTableView2()
        
    }
}

extension ViewController {
    private func bindTableView() {
        let cities = Observable.of(["Libson", "Copenhagen", "London", "Madrid", "Vienna"])
        
        cities
            .bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: String) in
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = element
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    private func bindTableView2() {
        observable.bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: MyModel) in
            let indexPath = IndexPath(item: index, section: 0)
            
            switch element {
            case .text(let title):
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
                cell.titleLb.text = title
                return cell
                
            case .pairOfImages(let firstImage, let secondImage):
                let cell = tableView.dequeueReusableCell(withIdentifier:
                "ImagesCell", for: indexPath) as! ImagesCell
                cell.firstImageView.image = firstImage
                cell.secondImageView.image = secondImage
                return cell
            }
        }
        .disposed(by: disposeBag)
    }
}
