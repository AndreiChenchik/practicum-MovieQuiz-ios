//
//  GameState.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 11/8/22.
//

import Foundation

struct GameState {
    var questions: [QuizQuestion] = []
    var currentQuestionIndex: Int = 0
    var currentScore: Int = 0

    var bestScore: Int = 0
    var bestScoreDate: Date = .distantPast

    var totalGamesCount: Int = 0
    var averageAnswerAccuracy: Double = 0.0

    var totalQuestions: Int { questions.count }
    var currentQuestion: QuizQuestion { questions[currentQuestionIndex] }
    var currentQuestionNumber: Int { currentQuestionIndex + 1 }
}
