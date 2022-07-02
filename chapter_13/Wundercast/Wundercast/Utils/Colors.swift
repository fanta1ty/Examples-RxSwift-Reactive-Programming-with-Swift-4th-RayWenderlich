import Foundation
import UIKit

public func colorFromDecimalRGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
  return UIColor(
    red: red / 255.0,
    green: green / 255.0,
    blue: blue / 255.0,
    alpha: alpha
  )
}

extension UIColor {

  // MARK: Custom Defined Colors

  /// Dark Blue Aztec
  class var aztec: UIColor {
    return colorFromDecimalRGB(38, 39, 41)
  }

  /// Light Cream Color
  class var lightCream: UIColor {
    return colorFromDecimalRGB(232, 234, 221)
  }

  /// Cream Color
  class var cream: UIColor {
    return colorFromDecimalRGB(229, 231, 218)
  }

  /// Swirl Color
  class var swirl: UIColor {
    return colorFromDecimalRGB(228, 221, 202)
  }

  /// Travertine Color
  class var travertine: UIColor {
    return colorFromDecimalRGB(214, 206, 195)
  }

  /// Green
  class var ufoGreen: UIColor {
    return colorFromDecimalRGB(64, 186, 145)
  }

  class var textGrey: UIColor {
    return colorFromDecimalRGB(146, 146, 146)
  }

}
