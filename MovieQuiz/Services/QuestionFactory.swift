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
    private let moviesLoader: MoviesLoading
    private let postersLoader: PostersLoading
    private weak var delegate: QuestionFactoryDelegate?

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
            guard
                let self = self,
                let movie = self.movies.randomElement()
            else { return }

            self.postersLoader.loadRandomPoster(movieId: movie.id) { result in
                switch result {
                case .success(let imageData):
                    let rating = Float(movie.rating) ?? 0

                    let text = "Рейтинг этого фильма больше чем 7?"
                    let correctAnswer = rating > 7

                    let question = QuizQuestion(
                        image: imageData, text: text, correctAnswer: correctAnswer
                    )

                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.didReceiveNextQuestion(question: question)
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.didFailToLoadData(with: error)
                    }
                }
            }
        }
    }
}
