import UIKit

final class MovieQuizViewController: UIViewController {
    private var state = GameState()

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        state.questions = getQuestionsMock()
        displayQuestion()
    }

    private func displayQuestion() {
        let questionViewModel = convert(
            from: state.currentQuestion,
            with: "\(state.currentQuestionNumber)/\(state.totalQuestions)"
        )

        show(quize: questionViewModel)
    }

    private func show(quize step: QuizeStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

        UIView.animate(withDuration: 0.25) {
            self.imageView.layer.borderWidth = 0
        }

        UIView.transition(
            with: imageView,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) {
            self.imageView.image = step.image
        } completion: { [weak self] _ in
            guard let self = self else { return }

            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }

    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false

        UIView.animate(withDuration: 0.25) {
            self.imageView.layer.masksToBounds = true
            self.imageView.layer.cornerRadius = 20

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

    private func processAnswer(answer: Bool) {
        let isCorrect = answer == state.currentQuestion.correctAnswer
        state.currentScore += isCorrect ? 1 : 0

        showAnswerResult(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.showNextQuestionOrResults()
        }
    }


    private func showNextQuestionOrResults() {
        if state.currentQuestionIndex >= state.totalQuestions - 1 {
            endGameSession()

            let resultsViewModel = convert(from: state)
            show(quize: resultsViewModel)

            state.currentScore = 0
            state.currentQuestionIndex = 0
        } else {
            state.currentQuestionIndex += 1
            displayQuestion()
        }
    }

    private func endGameSession() {
        let avgAccuracy = state.averageAnswerAccuracy
        let score = Double(state.currentScore)
        let totalGames = Double(state.totalGamesCount)
        let totalQuestions = Double(state.totalQuestions)

        state.averageAnswerAccuracy = (
            avgAccuracy * totalGames + score / totalQuestions
        ) / (totalGames + 1)

        if state.currentScore > state.bestScore {
            state.bestScore = state.currentScore
            state.bestScoreDate = Date()
        }

        state.totalGamesCount += 1
    }

    private func show(quize result: QuizeResultViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ) { _ in
            self.displayQuestion()
        }

        alert.addAction(action)

        self.present(alert, animated: true)
    }
}


// MARK: - Models

extension MovieQuizViewController {
    struct QuizeQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }

    struct GameState {
        var questions: [QuizeQuestion] = []
        var currentQuestionIndex: Int = 0
        var currentScore: Int = 0

        var bestScore: Int = 0
        var bestScoreDate: Date = .distantPast

        var totalGamesCount: Int = 0
        var averageAnswerAccuracy: Double = 0.0

        var totalQuestions: Int { questions.count }
        var currentQuestion: QuizeQuestion { questions[currentQuestionIndex] }
        var currentQuestionNumber: Int { currentQuestionIndex + 1 }
    }

    struct QuizeStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    struct QuizeResultViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
}


// MARK: - Data Converters

extension MovieQuizViewController {
    func convert(
        from model: QuizeQuestion,
        with number: String
    ) -> QuizeStepViewModel {
        let image = UIImage(named: model.image) ?? .remove
        let question = model.text
        let questionNumber = number

        let viewModel = QuizeStepViewModel(
            image: image,
            question: question,
            questionNumber: questionNumber
        )

        return viewModel
    }

    func convert(from state: GameState) -> QuizeResultViewModel {
        let title = "Этот раунд окончен!"
        let buttonText = "Сыграть еще раз"

        let totalQuestions = state.questions.count
        let accuracy = String(format: "%.2f", state.averageAnswerAccuracy * 100)

        let bestGameDate = state.bestScoreDate.dateTimeString
        let bestGame = "\(state.bestScore)/\(totalQuestions) (\(bestGameDate))"

        let text = """
        Ваш результат: \(state.currentScore)/\(totalQuestions)
        Количество сыграных квизов: \(state.totalGamesCount)
        Рекорд: \(bestGame)
        Средняя точность: \(accuracy)%
        """

        let viewModel = QuizeResultViewModel(
            title: title,
            text: text,
            buttonText: buttonText
        )

        return viewModel
    }
}



// MARK: - Mock Data

extension MovieQuizViewController {
    func getQuestionsMock() -> [QuizeQuestion] {
        let data = [
            QuizeQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true), // Настоящий рейтинг: 9,2
            QuizeQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true), // Настоящий рейтинг: 9
            QuizeQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true), // Настоящий рейтинг: 8,1
            QuizeQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true), // Настоящий рейтинг: 8
            QuizeQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true), // Настоящий рейтинг: 8
            QuizeQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true), // Настоящий рейтинг: 6,6
            QuizeQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false), // Настоящий рейтинг: 5,8
            QuizeQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false), // Настоящий рейтинг: 4,3
            QuizeQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false), // Настоящий рейтинг: 5,1
            QuizeQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false) // Настоящий рейтинг: 5,8
        ]

        return data
    }
}


// MARK: - StatusBar style

extension MovieQuizViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
