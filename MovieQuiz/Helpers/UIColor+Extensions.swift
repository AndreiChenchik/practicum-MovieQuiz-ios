import Foundation
import UIKit

extension UIColor {
    enum CustomColorAssets: String, CaseIterable {
        case ypBlack = "YP Black"
        case ypWhite = "YP White"
        case ypGreen = "YP Green"
        case ypRed = "YP Red"
        case ypGray = "YP Gray"
        case ypBackground = "YP Background"
    }

    static func getCustom(_ type: CustomColorAssets) -> UIColor {
        guard let color = UIColor(named: type.rawValue) else {
            preconditionFailure("Can't find color asset")
        }

        return color
    }
}
