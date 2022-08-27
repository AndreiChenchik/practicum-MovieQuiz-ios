import Foundation
import UIKit

extension UIColor {
    enum CustomColorAsset: String, CaseIterable {
        case ypBlack = "YP Black"
        case ypWhite = "YP White"
        case ypGreen = "YP Green"
        case ypRed = "YP Red"
        case ypGray = "YP Gray"
        case ypBackground = "YP Background"
    }

    static func getCustom(_ colorAsset: CustomColorAsset) -> UIColor {
        guard let color = UIColor(named: colorAsset.rawValue) else {
            return .clear
        }

        return color
    }
}
