import Cocoa

class TweetCellView: NSTableCellView {

  @IBOutlet var photo: NSImageView!
  @IBOutlet var name: NSTextField!
  @IBOutlet var message: NSTextField!

  func update(with tweet: Tweet) {
    name.stringValue = tweet.name
    message.stringValue = tweet.text
    photo.setImage(with: URL(string: tweet.imageUrl))
  }
}

