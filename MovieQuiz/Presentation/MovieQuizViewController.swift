import UIKit

final class MovieQuizViewController: UIViewController {
    private var presenter: MovieQuizPresenter?

    @IBOutlet private weak var imageViewContainer: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.accessibilityIdentifier = "Loading Indicator"
        return indicator
    }()
}


// MARK: - Lifecycle

extension MovieQuizViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureActivityIndicator()
        createPresenter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if
            let window = UIApplication.shared.windows.first,
            let bottomConstraint = view.constraints
                .filter({ $0.identifier == "stackViewLowerConstraint" }).first {
            let isDeviceWithoutButton = window.safeAreaInsets.bottom > 0
            bottomConstraint.constant = isDeviceWithoutButton ? 0 : 20
        }
    }
}


// MARK: - Dependencies

extension MovieQuizViewController {
    private func createPresenter() {
        let userDefaults = UserDefaults.standard
        let statisticService = StatisticsService(userDefaults: userDefaults)
        let resultPresenter = ResultPresenter(statisticService: statisticService)

        let urlSessionConfiguration = URLSessionConfiguration.default
        let size200mb = 200 * 1024 * 1024
        let urlCache = URLCache(
            memoryCapacity: size200mb,
            diskCapacity: size200mb
        )
        urlSessionConfiguration.urlCache = urlCache
        let urlSession = URLSession(
            configuration: urlSessionConfiguration
        )
        let networkClient = NetworkClient(urlSession: urlSession)

        let questionLoader = QuestionFactory(
            moviesLoader: MoviesLoader(networkClient: networkClient),
            postersLoader: PosterLoader(networkClient: networkClient)
        )

        let gameState = GameState()

        presenter = MovieQuizPresenter(
            statisticService: statisticService,
            questionLoader: questionLoader,
            resultPresenter: resultPresenter,
            state: gameState,
            viewController: self
        )

        questionLoader.delegate = presenter
    }
}


// MARK: - Setup UI

extension MovieQuizViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}


// MARK: - UI Events

extension MovieQuizViewController {
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.noButtonClicked()
    }
}


// MARK: - UI Updates

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func show(question model: QuizStepViewModel) {
        textLabel.text = model.question
        counterLabel.text = model.questionNumber

        imageViewContainer.animateBorderWidth(toValue: 0, duration: 0.25)

        UIView.transition(
            with: imageView,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) { [weak self] in
            self?.imageView.alpha = 1
            self?.imageView.image = model.image
        } completion: { [weak self] _ in
            guard let self = self else { return }

            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }

    func highlightImageBorder(isAnswerCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false

        imageViewContainer.layer.borderColor =
            isAnswerCorrect
            ? UIColor(colorAsset: .ypGreen).cgColor
            : UIColor(colorAsset: .ypRed).cgColor
        imageViewContainer.animateBorderWidth(toValue: 8, duration: 0.25)
    }

    func showNetworkError(message: String) {
        activityIndicator.stopAnimating()

        let alertController = UIAlertController(
            title: "Error", message: message, preferredStyle: .alert
        )

        let alertAction = UIAlertAction(
            title: "Try again",
            style: .default
        ) { [weak presenter] _ in
            presenter?.retryLoadingOnError()
        }

        alertController.addAction(alertAction)

        present(alertController, animated: true)
    }
}
