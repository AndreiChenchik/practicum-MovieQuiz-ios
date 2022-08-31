import UIKit

extension UIView {
    func animateBorderWidth(toValue: CGFloat, duration: Double = 0.3) {
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.fromValue = layer.borderWidth
        animation.toValue = toValue
        animation.duration = duration
        animation.timingFunction = .init(name: .easeOut)
        layer.add(animation, forKey: "Width")
        layer.borderWidth = toValue
    }
}
