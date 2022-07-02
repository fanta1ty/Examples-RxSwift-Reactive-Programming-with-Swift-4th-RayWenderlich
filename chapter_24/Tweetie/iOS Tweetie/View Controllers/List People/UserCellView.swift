import Foundation
import UIKit

class UserCellView: UITableViewCell {

  @IBOutlet weak var photo: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var message: UITextView!

  func update(with user: User) {
    name.text = user.name
    message.text = user.about
    photo.setImage(with: URL(string: user.imageUrl))
  }
}
