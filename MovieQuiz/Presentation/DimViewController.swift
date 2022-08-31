import UIKit

class DimViewController: UIViewController {
    private let dimView = UIView()
    private let dimmedViewController: UIViewController

    override var modalPresentationStyle: UIModalPresentationStyle {
        get { .overFullScreen }
        set {}
    }

    init(dimmedViewController: UIAlertController) {
        self.dimmedViewController = dimmedViewController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDimView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        present(dimmedViewController, animated: animated)
        switchDimScreen(isEnabled: true)
    }

    func configureDimView() {
        view.addSubview(dimView)

        dimView.backgroundColor = .clear

        dimView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: self.view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    func switchDimScreen(isEnabled: Bool) {
        UIView.transition(
            with: dimView,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) { [weak self] in
            self?.dimView.backgroundColor =
            isEnabled
            ? .init(colorAsset: .ypBackground)
            : .clear
        }
    }
}


// MARK: - DimmedViewControllerDelegate

extension DimViewController: DimmedViewControllerDelegate {
    func dimmedViewWillDisappear() {
        switchDimScreen(isEnabled: false)
    }

    func dimmedViewDidDisappear() {
        dismiss(animated: false)
    }
}
