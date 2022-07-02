import UIKit
import RxSwift
import RxRelay

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!

  private let bag = DisposeBag()
  private let images = BehaviorRelay<[UIImage]>(value: [])
  private var imageCache = [Int]()

  override func viewDidLoad() {
    super.viewDidLoad()

    images
      .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
      .subscribe(onNext: { [weak imagePreview] photos in
        guard let preview = imagePreview else { return }

        preview.image = photos.collage(size: preview.frame.size)
      })
      .disposed(by: bag)

    images
      .subscribe(onNext: { [weak self] photos in
        self?.updateUI(photos: photos)
      })
      .disposed(by: bag)
  }
  
  @IBAction func actionClear() {
    images.accept([])
    imageCache = []
  }

  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }

    PhotoWriter.save(image)
      .subscribe(
        onSuccess: { [weak self] id in
          self?.showMessage("Saved with id: \(id)")
          self?.actionClear()
        },
        onError: { [weak self] error in
          self?.showMessage("Error", description: error.localizedDescription)
        }
      )
      .disposed(by: bag)
  }

  @IBAction func actionAdd() {
    // images.accept(images.value + [UIImage(named: "IMG_1907.jpg")!])

    let photosViewController = storyboard!.instantiateViewController(
      withIdentifier: "PhotosViewController") as! PhotosViewController

    navigationController!.pushViewController(photosViewController, animated: true)

    let newPhotos = photosViewController.selectedPhotos.share()
    
    newPhotos
      .takeWhile { [weak self] image in
        let count = self?.images.value.count ?? 0
        return count < 6
      }
      .filter { newImage in
        return newImage.size.width > newImage.size.height
      }
      .filter { [weak self] newImage in
        let len = newImage.pngData()?.count ?? 0
        guard self?.imageCache.contains(len) == false else { return false }
        
        self?.imageCache.append(len)
        return true
      }
      .subscribe(
        onNext: { [weak self] newImage in
          guard let images = self?.images else { return }
          images.accept(images.value + [newImage])
        },
        onDisposed: {
          print("completed photo selection")
        }
      )
      .disposed(by: bag)
    
    newPhotos
      .ignoreElements()
      .subscribe(onCompleted: { [weak self] in
        self?.updateNavigationIcon()
      })
      .disposed(by: bag)
  }

  func showMessage(_ title: String, description: String? = nil) {
    alert(title: title, text: description)
      .subscribe()
      .disposed(by: bag)
  }

  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
  
  private func updateNavigationIcon() {
    let icon = imagePreview.image?
      .scaled(CGSize(width: 22, height: 22))
      .withRenderingMode(.alwaysOriginal)
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
                                                       style: .done,
                                                       target: nil,
                                                       action: nil)
  }
}
