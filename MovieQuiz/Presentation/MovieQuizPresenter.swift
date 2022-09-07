import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0

    func convert(
        from model: QuizQuestion,
        with number: String? = nil
    ) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? .remove
        let question = model.text
        let questionNumber = number
            ?? "\(currentQuestionIndex + 1)/\(questionsAmount)"

        let viewModel = QuizStepViewModel(
            image: image,
            question: question,
            questionNumber: questionNumber
        )

        return viewModel
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
