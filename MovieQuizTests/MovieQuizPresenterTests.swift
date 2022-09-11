import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: UIViewController,
    MovieQuizViewControllerProtocol {
    func show(question model: QuizStepViewModel) {}
    func highlightImageBorder(isAnswerCorrect: Bool) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func showNetworkError(message: String) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()

        let statisticsService = StatisticsService(userDefaults: TestDefaults())
        let networkClient = NetworkClient(urlSession: URLSession.shared)
        let moviesLoader = MoviesLoader(networkClient: networkClient)
        let postersLoader = PosterLoader(networkClient: networkClient)
        let questionLoader = QuestionFactory(
            moviesLoader: moviesLoader, postersLoader: postersLoader
        )
        let resultPresenter = ResultPresenter(
            statisticService: statisticsService
        )

        let sut = MovieQuizPresenter(
            statisticService: statisticsService,
            questionLoader: questionLoader,
            resultPresenter: resultPresenter,
            state: GameState(),
            viewController: viewControllerMock
        )

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(from: question, number: "1/10")

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
