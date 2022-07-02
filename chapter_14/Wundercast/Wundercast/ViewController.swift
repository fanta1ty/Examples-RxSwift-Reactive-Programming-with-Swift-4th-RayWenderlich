import UIKit
import RxSwift
import RxCocoa
import MapKit
import CoreLocation

typealias Weather = ApiController.Weather

class ViewController: UIViewController {
    
    @IBOutlet weak var keyButton: UIButton!
    @IBOutlet weak var geoLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchCityName: UITextField!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    private let bag = DisposeBag()
    private let locationManager = CLLocationManager()
    private var cache = [String: Weather]()
    
    var keyTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        
        keyButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.requestKey()
            })
            .disposed(by:bag)
        
        let currentLocation = locationManager.rx.didUpdateLocations
            .map { locations in locations[0] }
            .filter { location in
                return location.horizontalAccuracy == kCLLocationAccuracyNearestTenMeters
            }
        
        let geoInput = geoLocationButton.rx.tap
            .do(onNext: { [weak self] _ in
                self?.locationManager.requestWhenInUseAuthorization()
                self?.locationManager.startUpdatingLocation()
                
                self?.searchCityName.text = "Current Location"
            })
        
                let geoLocation = geoInput.flatMap {
                    return currentLocation.take(1)
                }
                
                let geoSearch = geoLocation.flatMap { location in
                    return ApiController.shared.currentWeather(at: location.coordinate)
                        .catchErrorJustReturn(.empty)
                }
                
                let searchInput = searchCityName.rx.controlEvent(.editingDidEndOnExit)
                .map { [weak self] _ in self?.searchCityName.text ?? "" }
                .filter { !$0.isEmpty }
        
        let textSearch = searchInput.flatMap { text in
            return ApiController.shared.currentWeather(city: text)
                .do(onNext: { [weak self] data in
                    guard let self = self else { return }
                    self.cache[text] = data
                })
                    .catchError { error in
                        return Observable.just(self.cache[text] ?? .empty)
                    }
        }
        
        let search = Observable.merge(geoSearch, textSearch)
            .asDriver(onErrorJustReturn: .empty)
        
        let running = Observable.merge(searchInput.map { _ in true },
                                       geoInput.map { _ in true },
                                       search.map { _ in false }.asObservable())
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        search.map { "\($0.temperature)° C" }
            .drive(tempLabel.rx.text)
            .disposed(by:bag)
        
        search.map(\.icon)
            .drive(iconLabel.rx.text)
            .disposed(by:bag)
        
        search.map { "\($0.humidity)%" }
            .drive(humidityLabel.rx.text)
            .disposed(by:bag)
        
        search.map(\.cityName)
            .drive(cityNameLabel.rx.text)
            .disposed(by:bag)
        
        running.skip(1).drive(activityIndicator.rx.isAnimating).disposed(by:bag)
        running.drive(tempLabel.rx.isHidden).disposed(by:bag)
        running.drive(iconLabel.rx.isHidden).disposed(by:bag)
        running.drive(humidityLabel.rx.isHidden).disposed(by:bag)
        running.drive(cityNameLabel.rx.isHidden).disposed(by:bag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Appearance.applyBottomLine(to: searchCityName)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func requestKey() {
        func configurationTextField(textField: UITextField!) {
            self.keyTextField = textField
        }
        
        let alert = UIAlertController(title: "Api Key",
                                      message: "Add the api key:",
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            ApiController.shared.apiKey.onNext(self?.keyTextField?.text ?? "")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Style
    
    private func style() {
        view.backgroundColor = UIColor.aztec
        searchCityName.textColor = UIColor.ufoGreen
        tempLabel.textColor = UIColor.cream
        humidityLabel.textColor = UIColor.cream
        iconLabel.textColor = UIColor.cream
        cityNameLabel.textColor = UIColor.cream
    }
}
