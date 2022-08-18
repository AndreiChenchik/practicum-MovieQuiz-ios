import UIKit

final class MovieQuizViewController: UIViewController {
    private var state = GameState()

    private var questionFactory: QuestionFactoryProtocol?
    private var resultPresenter: ResultPresenterProtocol?
    private var statisticService: StatisticsService?

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    private var activityIndicator = {
        let indicator = UIActivityIndicatorView()
        indicator.isHidden = true

        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureActivityIndicator()

        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(), delegate: self
        )
        statisticService = StatisticServiceImplementation()
        resultPresenter = ResultPresenter()

        showLoadingIndicator()
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

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true

        let alertController = UIAlertController(
            title: "Error", message: message, preferredStyle: .alert
        )

        let alertAction = UIAlertAction(
            title: "Try again",
            style: .default
        ) { _ in
            print("Button pressed")
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
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
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
        activityIndicator.isHidden = true

        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        self.state.currentQuestion = question
        self.state.currentQuestionNumber += 1

        let questionNumber = self.state.currentQuestionNumber
        let questionsAmmount = self.state.questionsAmount
        let questionViewModel = convert(
            from: question,
            with: "\(questionNumber)/\(questionsAmmount)"
        )

        DispatchQueue.main.async {
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

            let resultsViewModel = convert(from: state)

            resultPresenter?.displayResults(
                resultsViewModel,
                over: self
            ) { [weak self] in
                self?.questionFactory?.requestNextQuestion()
            }

            state.currentScore = 0
            state.currentQuestionNumber = 0
        } else {
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

    private func convert(from state: GameState) -> QuizResultViewModel {
        let isIdealSession = state.currentScore == state.questionsAmount
        let title =
            isIdealSession
            ? "Идеальный результат!"
            : "Этот раунд окончен!"

        let buttonText = "Сыграть еще раз"

        let totalQuestions = state.questionsAmount

        let totalAccuracy = statisticService?.totalAccuracy ?? 0.0
        let accuracyDescription = String(format: "%.2f", totalAccuracy * 100)

        let bestDate = statisticService?.bestGame.date ?? Date()
        let bestDateDescription = bestDate.dateTimeString
        let bestScore = statisticService?.bestGame.correct ?? 0
        let bestTotalQuestions = statisticService?.bestGame.total ?? 0
        let totalGames = statisticService?.gamesCount ?? 0

        let text = """
        Ваш результат: \(state.currentScore)/\(totalQuestions)
        Количество сыграных квизов: \(totalGames)
        Рекорд: \(bestScore)/\(bestTotalQuestions) (\(bestDateDescription))
        Средняя точность: \(accuracyDescription)%
        """

        let viewModel = QuizResultViewModel(
            title: title,
            text: text,
            buttonText: buttonText
        )

        return viewModel
    }
}


// MARK: - StatusBar style

extension MovieQuizViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
