//
//  GameState.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 11/8/22.
//

import Foundation

struct GameState {
    var questionsAmount = 10
    var currentQuestion: QuizQuestion?
    var currentQuestionNumber = 0
    var currentScore = 0
}
