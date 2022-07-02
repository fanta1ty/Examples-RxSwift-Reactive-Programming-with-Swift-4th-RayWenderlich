//
//  ViewController.swift
//  DemoRxSwift
//
//  Created by User on 25/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ViewController: UIViewController {
    @IBOutlet var contentView: UIView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        contentView.rx.tapGesture()
//            .when(.recognized)
//            .subscribe(onNext: { _ in
//                print("Content View Tapped!")
//            })
//            .disposed(by: disposeBag)
        
//        contentView.rx.anyGesture(.tap(), .longPress())
//            .when(.recognized)
//            .subscribe(onNext: { [weak contentView] gesture in
//                if let tap = gesture as? UITapGestureRecognizer {
//                    print("Content View was tap at \(tap.location(in: contentView))")
//                } else {
//                    print("Content View was Long Pressed!")
//                }
//            })
//            .disposed(by: disposeBag)
        
//        contentView.rx.tapGesture()
//            .when(.recognized)
//            .asLocation(in: .window)
//            .subscribe(onNext: { location in
//                print("Location \(location)")
//            })
//            .disposed(by: disposeBag)
        
//        contentView.rx.panGesture()
//            .asTranslation(in: .superview)
//            .subscribe(onNext: { translation, velocity in
//                print("Translation: \(translation) - Velocity: \(velocity)")
//            })
//            .disposed(by: disposeBag)
        
//        contentView.rx.rotationGesture()
//            .asRotation()
//            .subscribe(onNext: { rotation, velocity in
//                print("Rotation: \(rotation), velocity: \(velocity)")
//            })
//            .disposed(by: disposeBag)
        
//        contentView.rx.transformGestures()
//            .asTransform()
//            .subscribe(onNext: { [unowned contentView] transform, velocity in
//                contentView?.transform = transform
//
//            })
//            .disposed(by: disposeBag)
        
        let panGesture = contentView.rx.panGesture().share(replay: 1)
        
        panGesture
            .when(.changed)
            .asTranslation()
            .subscribe(onNext: { [unowned contentView] translation, _ in
                contentView?.transform = CGAffineTransform(translationX: translation.x,
                                                           y: translation.y)
                
            })
            .disposed(by: disposeBag)
        
        panGesture
            .when(.ended)
            .subscribe(onNext: { _ in
                print("Done panning")
            })
            .disposed(by: disposeBag)
    }
}
