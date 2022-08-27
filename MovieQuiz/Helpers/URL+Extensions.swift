//
//  URL+Extensions.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 27/8/22.
//

import Foundation

extension URL {
    enum ImdbEndpoint: String, CaseIterable {
        case mostPopularMovies = "%baseUrl%/MostPopularMovies/%apiKey%"
        case moviePostersBase = "%baseUrl%/Posters/%apiKey%"
    }

    static func imdbUrl(_ imdbEndpoint: ImdbEndpoint) -> URL {
        let baseUrl = "https://imdb-api.com/en/API"
        let apiKey = "k_kiwxbi4y"

        let urlString = imdbEndpoint.rawValue
            .replacingOccurrences(of: "%baseUrl%", with: baseUrl)
            .replacingOccurrences(of: "%apiKey%", with: apiKey)

        return URL(string: urlString) ?? URL(fileURLWithPath: "/")
    }
}
