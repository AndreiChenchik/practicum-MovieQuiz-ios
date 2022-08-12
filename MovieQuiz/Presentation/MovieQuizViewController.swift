import UIKit

struct MoviesList: Codable {
    let items: [Movie]
}
struct Movie: Codable {
    let id: String
    let rank: Int
    let title: String
    let fullTitle: String
    let year: Int
    let image: String
    let crew: String
    let imDbRating: Double
    let imDbRatingCount: Int

    enum CodingKeys: String, CodingKey {
       case id, rank, title, fullTitle, year, image, crew, imDbRating, imDbRatingCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        fullTitle = try container.decode(String.self, forKey: .fullTitle)
        image = try container.decode(String.self, forKey: .image)
        crew = try container.decode(String.self, forKey: .crew)

        let rank = try container.decode(String.self, forKey: .rank)
        self.rank = Int(rank)!

        let year = try container.decode(String.self, forKey: .year)
        self.year = Int(year)!

        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        self.imDbRating = Double(imDbRating)!

        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        self.imDbRatingCount = Int(imDbRatingCount)!
    }
}

final class MovieQuizViewController: UIViewController {
    private var state = GameState()
    private var resultPresenter = ResultPresenter()

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let fileManager = FileManager.default
        var documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        let fileName = "top250MoviesIMDB.json"
        let fileUrl = documentsURL.appendingPathComponent(fileName)

        if let data = fileManager.contents(atPath: fileUrl.path) {
           let moviesList = try! JSONDecoder().decode(MoviesList.self, from: data)
            for movie in moviesList.items {
                print(movie)
            }
        }

        state.questionFactory = QuestionFactory(delegate: self)
        state.questionFactory?.requestNextQuestion()
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
            endGameSession()

            let resultsViewModel = convert(from: state)

            resultPresenter.displayResults(
                resultsViewModel,
                over: self
            ) { [weak self] in
                self?.state.questionFactory?.requestNextQuestion()
            }

            state.currentScore = 0
            state.currentQuestionNumber = 0
        } else {
            state.questionFactory?.requestNextQuestion()
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
