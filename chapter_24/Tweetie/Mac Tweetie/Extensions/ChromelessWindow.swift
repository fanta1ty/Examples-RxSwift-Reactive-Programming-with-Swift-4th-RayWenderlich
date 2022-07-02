import Cocoa

class ChromelessWindow: NSWindow {
  //hides window title bar
  override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = NSColor.windowBackgroundColor
    styleMask.insert(.fullSizeContentView)
    titlebarAppearsTransparent = true
  }
}
