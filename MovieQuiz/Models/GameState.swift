//
//  GameState.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 11/8/22.
//

import Foundation

struct GameState {
    var questionFactory: QuestionFactoryProtocol?

    var questionsAmount = 10
    var currentQuestion: QuizQuestion?
    var currentQuestionNumber = 0

    var currentScore = 0
    var bestScore = 0
    var bestScoreDate: Date = .distantPast

    var totalGamesCount = 0
    var averageAnswerAccuracy = 0.0
}
