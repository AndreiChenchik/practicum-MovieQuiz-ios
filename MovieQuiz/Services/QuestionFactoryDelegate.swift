//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 11/8/22.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didRecieveNextQuestion(question: QuizQuestion?)
}
