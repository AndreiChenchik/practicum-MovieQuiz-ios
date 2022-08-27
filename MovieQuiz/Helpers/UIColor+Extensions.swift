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

    convenience init(colorAsset: CustomColorAsset) {
        let color = UIColor(named: colorAsset.rawValue) ?? .clear
        self.init(cgColor: color.cgColor)
    }
}
