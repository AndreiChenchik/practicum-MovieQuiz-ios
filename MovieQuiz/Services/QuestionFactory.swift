import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

protocol PostersLoading {
    func loadPosterData(
        movieId: String,
        handler: @escaping (Result<Data, Error>) -> Void
    )
}

protocol MoviesLoading {
    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    )
}

class QuestionFactory {
    enum FactoryError: Error {
        case noMoviesFound
    }

    private let moviesLoader: MoviesLoading
    private let postersLoader: PostersLoading
    private weak var delegate: QuestionFactoryDelegate?

    private var nextQuestionResult: Result<QuizQuestion, Error>?

    private var movies: [MostPopularMovie] = []

    init(
        moviesLoader: MoviesLoading,
        postersLoader: PostersLoading,
        delegate: QuestionFactoryDelegate
    ) {
        self.moviesLoader = moviesLoader
        self.postersLoader = postersLoader
        self.delegate = delegate
    }

    private func loadQuestion(
        handler: @escaping (Result<QuizQuestion, Error>) -> Void
    ) {
        guard let movie = movies.randomElement() else {
            handler(.failure(FactoryError.noMoviesFound))
            return
        }

        postersLoader.loadPosterData(movieId: movie.id) { result in
            switch result {
            case .success(let imageData):
                let rating = Float(movie.rating) ?? 0

                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7

                let question = QuizQuestion(
                    image: imageData,
                    text: text,
                    correctAnswer: correctAnswer
                )

                handler(.success(question))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    private func preloadNextQuestion() {
        nextQuestionResult = nil

        self.loadQuestion { [weak self] result in
            switch result {
            case .success(let data):
                self?.nextQuestionResult = .success(data)
            default:
                break
            }
        }
    }

    private func dispatchResult(result: Result<QuizQuestion, Error>) {
        switch result {
        case .success(let question):
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveNextQuestion(
                    question: question
                )
            }
        case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didFailToLoadData(with: error)
            }
        }

        preloadNextQuestion()
    }
}


// MARK: - QuestionLoading

extension QuestionFactory: QuestionLoading {
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items
                self.delegate?.didLoadDataFromServer()
            case .failure(let error):
                self.delegate?.didFailToLoadData(with: error)
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            if let questionResult = self.nextQuestionResult {
                self.dispatchResult(result: questionResult)
            } else {
                self.loadQuestion { [weak self] result in
                    self?.dispatchResult(result: result)
                }
            }
        }
    }
}
