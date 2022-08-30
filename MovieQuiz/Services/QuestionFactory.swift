//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 11/8/22.
//

import Foundation

protocol QuestionFactoryProtocol {
    func loadData()
    func requestNextQuestion()
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

class QuestionFactory: QuestionFactoryProtocol {
    enum FactoryError: Error {
        case noMoviesFound
    }

    private let moviesLoader: MoviesLoading
    private let postersLoader: PostersLoading
    private weak var delegate: QuestionFactoryDelegate?

    private var nextQuestionResult: Result<QuizQuestion, Error>?

    private var movies: [MostPopularMovie] = []

//    private let questions = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true), // Настоящий рейтинг: 9,2
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true), // Настоящий рейтинг: 9
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true), // Настоящий рейтинг: 8,1
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true), // Настоящий рейтинг: 8
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true), // Настоящий рейтинг: 8
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true), // Настоящий рейтинг: 6,6
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false), // Настоящий рейтинг: 5,8
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false), // Настоящий рейтинг: 4,3
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false), // Настоящий рейтинг: 5,1
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false) // Настоящий рейтинг: 5,8
//    ]

    init(
        moviesLoader: MoviesLoading,
        postersLoader: PostersLoading,
        delegate: QuestionFactoryDelegate
    ) {
        self.moviesLoader = moviesLoader
        self.postersLoader = postersLoader
        self.delegate = delegate
    }

    private func loadNextQuestion(
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

        self.loadNextQuestion { [weak self] in
            self?.nextQuestionResult = $0
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
                self.loadNextQuestion { [weak self] result in
                    self?.dispatchResult(result: result)
                }
            }
        }
    }
}
