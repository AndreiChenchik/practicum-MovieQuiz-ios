import UIKit

final class ResultPresenter: ResultPresenting {
    let statisticService: StatisticsStoring & StatisticsReporting

    init(statisticService: StatisticsStoring & StatisticsReporting) {
        self.statisticService = statisticService
    }

    func displayResults(
        from state: GameState,
        over viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let model = convert(from: state)

        let alertController = ResultAlertController(
            title: model.title,
            message: model.text,
            preferredStyle: .alert
        )

        let dimViewController = DimViewController(dimmedViewController: alertController)

        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            completion()
        }

        alertController.addAction(action)
        alertController.delegate = dimViewController

        viewController.present(dimViewController, animated: false)
    }

    private func convert(from state: GameState) -> QuizResultViewModel {
        let totalQuestions = state.questionsAmount
        let isIdealSession = state.currentScore == totalQuestions

        let title =
            isIdealSession
            ? "Идеальный результат!"
            : "Этот раунд окончен!"
        let buttonText = "Сыграть еще раз"

        let totalAccuracy = statisticService.totalAccuracy
        let accuracyDescription = String(format: "%.2f", totalAccuracy * 100)

        let bestDate = statisticService.bestGame.date
        let bestDateDescription = bestDate.dateTimeString
        let bestScore = statisticService.bestGame.correct
        let bestTotalQuestions = statisticService.bestGame.total
        let totalGames = statisticService.gamesCount

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
