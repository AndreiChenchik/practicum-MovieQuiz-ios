import UIKit

final class MovieQuizViewController: UIViewController {
    private var state = GameState()

    private var questionFactory: QuestionFactoryProtocol?
    private var resultPresenter: ResultPresenting?
    private var statisticService: StatisticsService?

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

        configureActivityIndicator()

        let urlSession = URLSession.shared
        let networkClient = NetworkClient(urlSession: urlSession)
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(networkClient: networkClient),
            postersLoader: PostersLoader(networkClient: networkClient),
            delegate: self
        )

        let userDefaults = UserDefaults.standard
        let statisticService = StatisticServiceImpl(userDefaults: userDefaults)
        self.statisticService = statisticService

        resultPresenter = ResultPresenter(statisticService: statisticService)

        loadData()
    }

    private func loadData() {
        activityIndicator.startAnimating()
        questionFactory?.loadData()
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

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.imageView.layer.borderWidth = 0
        }

        UIView.transition(
            with: imageView,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) { [weak self] in
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

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }

            self.imageView.layer.borderWidth = 8
            self.imageView.layer.borderColor =
            isAnswerCorrect
            ? UIColor(colorAsset: .ypGreen).cgColor
            : UIColor(colorAsset: .ypRed).cgColor
        }
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
        questionFactory?.requestNextQuestion()
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
                correct: state.currentScore, total: state.questionsAmount
            )

            resultPresenter?.displayResults(
                from: state,
                over: self
            ) { [weak self] in
                self?.questionFactory?.requestNextQuestion()
            }

            state.currentScore = 0
            state.currentQuestionNumber = 0
        } else {
            activityIndicator.startAnimating()
            questionFactory?.requestNextQuestion()
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
