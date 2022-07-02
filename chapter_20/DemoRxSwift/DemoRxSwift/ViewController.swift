//
//  ViewController.swift
//  DemoRxSwift
//
//  Created by User on 25/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Action

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    private let disposeBag = DisposeBag()
    
    private let buttonAction: Action<Void, Void> = Action {
        print("Doing some work")
        return Observable.empty()
    }
    
    private let loginAction: Action<(String?, String?), Bool> = Action { credentials in
        let (login, password) = credentials
        print("Login: \(credentials.0 ?? "Default Login") - Password: \(credentials.1 ?? "Default Password")")
        return Observable.just(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.rx.action = buttonAction
        
        let loginPasswordObservable = Observable
            .combineLatest(loginField.rx.text, passwordField.rx.text) { ($0, $1) }
        
        button.rx.tap
            .withLatestFrom(loginPasswordObservable)
            .bind(to: loginAction.inputs)
            .disposed(by: disposeBag)
        
        loginAction.elements
            .filter { $0 }
            .take(1)
            .subscribe(onNext: { data in
                print("Login completed: \(data)")
            })
            .disposed(by: disposeBag)
        
        loginAction
            .errors
            .subscribe(onError: { error in
                print("Warning! Error: \(error)")
            })
            .disposed(by: disposeBag)
        
        loginAction
            .execute(("John", "12345"))
            .subscribe(onNext: { data in
                print("Execute default! \(data)")
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        button.rx.action = nil
    }
}
