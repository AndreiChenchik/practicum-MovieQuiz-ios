import UIKit

final class MovieQuizViewController: UIViewController {
    private var state = GameState(questionFactory: QuestionFactory())

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    @IBOutlet private weak var dimView: UIView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        displayNextQuestion()
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

    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false

        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }

            self.imageView.layer.borderWidth = 8
            self.imageView.layer.borderColor =
            isCorrect
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


// MARK: - Game logic

extension MovieQuizViewController {
    private func displayNextQuestion() {
        state.currentQuestion = state.questionFactory.requestNextQuestion()

        if let currentQuestion = state.currentQuestion {
            let questionViewModel = convert(
                from: currentQuestion,
                with: "\(state.currentQuestionNumber)/\(state.questionsAmount)"
            )

            show(question: questionViewModel)
        }
    }

    private func processAnswer(answer: Bool) {
        guard let currentQuestion = state.currentQuestion else { return }

        let isCorrect = answer == currentQuestion.correctAnswer
        state.currentScore += isCorrect ? 1 : 0

        showAnswerResult(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if state.currentQuestionNumber >= state.questionsAmount {
            endGameSession()

            let resultsViewModel = convert(from: state)
            show(result: resultsViewModel)

            state.currentScore = 0
            state.currentQuestionNumber = 1
        } else {
            state.currentQuestionNumber += 1
            displayNextQuestion()
        }
    }

    private func endGameSession() {
        let avgAccuracy = state.averageAnswerAccuracy
        let score = Double(state.currentScore)
        let totalGames = Double(state.totalGamesCount)
        let totalQuestions = Double(state.questionsAmount)

        state.averageAnswerAccuracy = (
            avgAccuracy * totalGames + score / totalQuestions
        ) / (totalGames + 1)

        if state.currentScore > state.bestScore {
            state.bestScore = state.currentScore
            state.bestScoreDate = Date()
        }

        state.totalGamesCount += 1
    }
}


// MARK: - Results UI

extension MovieQuizViewController {
    class ResultsAlertController: UIAlertController {
        var delegate: MovieQuizViewController?

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            delegate?.switchDimScreen(isEnabled: false)
        }
    }

    private func show(result model: QuizResultViewModel) {
        let alert = ResultsAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert
        )

        alert.delegate = self

        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            self.switchDimScreen(isEnabled: false)
            self.displayNextQuestion()
        }

        alert.addAction(action)

        self.switchDimScreen(isEnabled: true)
        self.present(alert, animated: true)
    }

    func switchDimScreen(isEnabled: Bool) {
        // On enable: Unhide first and then transition to background color
        if isEnabled {
            self.dimView.isHidden = !isEnabled
        }

        UIView.transition(
            with: dimView,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) { [weak self] in
            self?.dimView.backgroundColor =
                isEnabled
                ? .ypBackground
                : .clear
        } completion: { [weak self] _ in
            // On disable: Transition to clear color and then hide
            if !isEnabled {
                self?.dimView.isHidden = !isEnabled
            }
        }
    }
}


// MARK: - Data Converters

extension MovieQuizViewController {
    private func convert(
        from model: QuizQuestion,
        with number: String
    ) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? .remove
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
        let accuracy = String(format: "%.2f", state.averageAnswerAccuracy * 100)

        let bestGameDate = state.bestScoreDate.dateTimeString
        let bestGame = "\(state.bestScore)/\(totalQuestions) (\(bestGameDate))"

        let text = """
        Ваш результат: \(state.currentScore)/\(totalQuestions)
        Количество сыграных квизов: \(state.totalGamesCount)
        Рекорд: \(bestGame)
        Средняя точность: \(accuracy)%
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
