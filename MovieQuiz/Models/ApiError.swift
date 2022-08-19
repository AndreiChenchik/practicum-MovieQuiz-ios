//
//  ApiError.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 19/8/22.
//

import Foundation

enum ApiError: Error {
    case genericError(message: String)
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .genericError(let message):
            return NSLocalizedString(message, comment: "API generic error")
        }
    }
}
