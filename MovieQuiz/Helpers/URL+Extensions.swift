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
        let apiKey = "k_o7ds3xds"

        let urlString = imdbEndpoint.rawValue
            .replacingOccurrences(of: "%baseUrl%", with: baseUrl)
            .replacingOccurrences(of: "%apiKey%", with: apiKey)

        return URL(string: urlString) ?? URL(fileURLWithPath: "/")
    }
}

extension URL {
    enum TmdbEndpoint {
        case imdbMovieSearch(movieId: String)
        case posterURL(posterPath: String, posterSize: String = "w500")
    }

    static func tmdbUrl(_ tmdbEndpoint: TmdbEndpoint) -> URL {
        let apiBaseUrl = "https://api.themoviedb.org/3"
        let apiKey = "599cd15476ea5d49e4663aee7ba500a0"

        let imagesBaseUrl = "https://image.tmdb.org"

        var urlString: String
        switch tmdbEndpoint {
        case .imdbMovieSearch(let movieId):
            urlString =
                "\(apiBaseUrl)/find/\(movieId)" +
                "?api_key=\(apiKey)&external_source=imdb_id"
        case let .posterURL(posterPath, posterSize):
            urlString = "\(imagesBaseUrl)/t/p/\(posterSize)\(posterPath)"
        }

        return URL(string: urlString) ?? URL(fileURLWithPath: "/")
    }
}
