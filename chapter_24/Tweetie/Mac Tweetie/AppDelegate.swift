import Cocoa
import Accounts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let navigator = Navigator()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    guard let splitController = NSApp.windows.first?.contentViewController as? NSSplitViewController else {
      fatalError("Can't find content controller")
    }

    let account = TwitterAccount().default
    let list = (username: "icanzilb", slug: "RxSwift")

    navigator.show(segue: .listPeople(account, list), sender: splitController)
    navigator.show(segue: .listTimeline(account, list), sender: splitController)
  }
}
