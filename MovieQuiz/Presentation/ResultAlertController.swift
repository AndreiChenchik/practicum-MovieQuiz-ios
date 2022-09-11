import UIKit

protocol DimmedViewControllerDelegate: AnyObject {
    func dimmedViewWillDisappear()
    func dimmedViewDidDisappear()
}

final class ResultAlertController: UIAlertController {
    weak var delegate: DimmedViewControllerDelegate?

    override func viewWillDisappear(_ animated: Bool) {
        delegate?.dimmedViewWillDisappear()
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        delegate?.dimmedViewDidDisappear()
        super.viewDidDisappear(animated)
    }
}
