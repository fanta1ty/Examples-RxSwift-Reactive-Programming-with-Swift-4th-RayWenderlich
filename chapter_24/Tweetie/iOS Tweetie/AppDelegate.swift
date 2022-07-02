import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let navigator = Navigator()

  let account = TwitterAccount().default
  let list = (username: "icanzilb", slug: "RxSwift")
  let testing = NSClassFromString("XCTest") != nil

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if !testing {
      let feedNavigation = window!.rootViewController! as! UINavigationController
      navigator.show(segue: .listTimeline(account, list), sender: feedNavigation)
    }
    return true
  }
}

