import Cocoa

class UserCellView: NSTableCellView {

  @IBOutlet var photo: NSImageView!
  @IBOutlet var name: NSTextField!
  @IBOutlet var about: NSTextField!

  func update(with user: User) {
    name.stringValue = user.name
    about.stringValue = user.about
    photo.setImage(with: URL(string: user.imageUrl))
  }
}
