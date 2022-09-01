import UIKit

protocol QuestionLoading {
    func loadData()
    func requestNextQuestion()
}

protocol ResultPresenting {
    func displayResults(
        from state: GameState,
        over viewController: UIViewController,
        completion: @escaping () -> Void
    )
}

final class MovieQuizViewController: UIViewController {
    typealias StatisticsProtocols = StatisticsStoring & StatisticsReporting
    private var state = GameState()

    private var questionLoader: QuestionLoading?
    private var resultPresenter: ResultPresenting?
    private var statisticService: StatisticsProtocols?

    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    private var activityIndicator = {
        let indicator = UIActivityIndicatorView()
        indicator.accessibilityIdentifier = "Loading Indicator"
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setDependencies()
        loadData()
        configureActivityIndicator()
    }

    override func viewDidLayoutSubviews() {
        if
            let window = UIApplication.shared.windows.first,
            let bottomConstraint = view.constraints
                .filter({ $0.identifier == "stackViewLowerConstraint" }).first {
                    let isDeviceWithoutButton = window.safeAreaInsets.bottom > 0
                    bottomConstraint.constant = isDeviceWithoutButton ? 0 : 20
        }
    }

    private func setDependencies() {
        let userDefaults = UserDefaults.standard
        let statisticService = StatisticsService(userDefaults: userDefaults)
        self.statisticService = statisticService

        resultPresenter = ResultPresenter(statisticService: statisticService)

        prepareQuestionFactory()
    }

    private func prepareQuestionFactory() {
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
        questionLoader = QuestionFactory(
            moviesLoader: MoviesLoader(networkClient: networkClient),
            postersLoader: PosterLoader(networkClient: networkClient),
            delegate: self
        )
    }

    private func loadData() {
        activityIndicator.startAnimating()
        questionLoader?.loadData()
    }

    private func configureActivityIndicator() {
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()

        let alertController = UIAlertController(
            title: "Error", message: message, preferredStyle: .alert
        )

        let alertAction = UIAlertAction(
            title: "Try again",
            style: .default
        ) { [weak self] _ in
            self?.loadData()
        }

        alertController.addAction(alertAction)

        present(alertController, animated: true)
    }

    private func show(question model: QuizStepViewModel) {
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

    private func show(isAnswerCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false

        imageViewContainer.layer.borderColor =
            isAnswerCorrect
            ? UIColor(colorAsset: .ypGreen).cgColor
            : UIColor(colorAsset: .ypRed).cgColor
        imageViewContainer.animateBorderWidth(toValue: 8, duration: 0.25)
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        processAnswer(answer: true)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        processAnswer(answer: false)
    }
}


// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        questionLoader?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showNetworkError(message: error.localizedDescription)
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        self.state.currentQuestion = question
        self.state.currentQuestionNumber += 1

        let questionNumber = self.state.currentQuestionNumber
        let questionsAmount = self.state.questionsAmount
        let questionViewModel = convert(
            from: question,
            with: "\(questionNumber)/\(questionsAmount)"
        )

        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.show(question: questionViewModel)
        }
    }
}


// MARK: - Game logic

extension MovieQuizViewController {
    private func processAnswer(answer: Bool) {
        guard let currentQuestion = state.currentQuestion else { return }

        let isCorrect = answer == currentQuestion.correctAnswer
        state.currentScore += isCorrect ? 1 : 0

        show(isAnswerCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if state.currentQuestionNumber >= state.questionsAmount {
            statisticService?.store(
                correct: state.currentScore,
                total: state.questionsAmount,
                date: Date()
            )

            resultPresenter?.displayResults(
                from: state,
                over: self
            ) { [weak self] in
                self?.questionLoader?.requestNextQuestion()
            }

            state.currentScore = 0
            state.currentQuestionNumber = 0
        } else {
            activityIndicator.startAnimating()
            questionLoader?.requestNextQuestion()
        }
    }
}


// MARK: - Data Converters

extension MovieQuizViewController {
    private func convert(
        from model: QuizQuestion,
        with number: String
    ) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? .remove
        let question = model.text
        let questionNumber = number

        let viewModel = QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: questionNumber
        )

        return viewModel
    }
}


// MARK: - StatusBar style

extension MovieQuizViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
