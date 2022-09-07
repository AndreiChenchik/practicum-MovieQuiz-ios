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

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(question model: QuizStepViewModel)

    func highlightImageBorder(isAnswerCorrect: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
}

final class MovieQuizPresenter {
    private var state: GameState

    typealias StatisticsProtocols = StatisticsStoring & StatisticsReporting
    private let statisticService: StatisticsProtocols

    private let questionLoader: QuestionLoading
    private let resultPresenter: ResultPresenting

    typealias VCProtocols = MovieQuizViewControllerProtocol & UIViewController
    weak var viewController: VCProtocols?

    init(
        statisticService: StatisticsProtocols,
        questionLoader: QuestionLoading,
        resultPresenter: ResultPresenting,
        state: GameState,
        viewController: VCProtocols
    ) {
        self.state = state
        self.statisticService = statisticService
        self.questionLoader = questionLoader
        self.resultPresenter = resultPresenter
        self.viewController = viewController

        viewController.showLoadingIndicator()
        questionLoader.loadData()
    }
}

// MARK: - UI Events

extension MovieQuizPresenter {
    func retryLoadingOnError() {
        questionLoader.loadData()
    }

    func yesButtonClicked() {
        processAnswer(answer: true)
    }

    func noButtonClicked() {
        processAnswer(answer: false)
    }
}

// MARK: - Data Events (QuestionFactoryDelegate)

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        questionLoader.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.showNetworkError(message: error.localizedDescription)
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        state.currentQuestion = question
        increaseQuestionNumber()

        let number = "\(state.currentQuestionNumber)/\(state.questionsAmount)"
        let questionViewModel = convert(from: question, number: number)

        DispatchQueue.main.async { [viewController] in
            viewController?.hideLoadingIndicator()
            viewController?.show(question: questionViewModel)
        }
    }
}

// MARK: - State Management

extension MovieQuizPresenter {
    private var isLastQuestion: Bool {
        state.currentQuestionNumber >= state.questionsAmount
    }

    private func resetQuestionNumber() {
        state.currentQuestionNumber = 0
    }

    private func resetScore() {
        state.currentScore = 0
    }

    private func increaseQuestionNumber() {
        state.currentQuestionNumber += 1
    }
}


// MARK: - Game Logic

extension MovieQuizPresenter {
    private func processAnswer(answer: Bool) {
        guard
            let currentQuestion = state.currentQuestion,
            let viewController = viewController
        else { return }

        let isCorrect = answer == currentQuestion.correctAnswer
        state.currentScore += isCorrect ? 1 : 0

        viewController.highlightImageBorder(isAnswerCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        guard let viewController = viewController else { return }

        if isLastQuestion {
            statisticService.store(
                correct: state.currentScore,
                total: state.questionsAmount,
                date: Date()
            )

            resultPresenter.displayResults(
                from: state,
                over: viewController
            ) { [weak self] in
                self?.questionLoader.requestNextQuestion()
            }

            state.currentScore = 0
            resetQuestionNumber()
        } else {
            viewController.showLoadingIndicator()
            questionLoader.requestNextQuestion()
        }
    }
}


// MARK: - Data Adapters

extension MovieQuizPresenter {
    func convert(from model: QuizQuestion, number: String) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? .remove
        let question = model.text

        let viewModel = QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: number
        )

        return viewModel
    }
}
