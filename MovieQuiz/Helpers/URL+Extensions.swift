//
//  URL+Extensions.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 27/8/22.
//

import Foundation

extension URL {
    enum IMDBendpoint: String {
        case mostPopularMovies = "%baseUrl%/MostPopularMovies/%apiKey%"
        case moviePostersBase = "%baseUrl%/Posters/%apiKey%"

        var endpointURL: URL {
            let baseUrl = "https://imdb-api.com/en/API"
            let apiKey = "k_o7ds3xds"

            let urlString = self.rawValue
                .replacingOccurrences(of: "%baseUrl%", with: baseUrl)
                .replacingOccurrences(of: "%apiKey%", with: apiKey)

            return URL(string: urlString) ?? URL(fileURLWithPath: "/")
        }
    }

    static func apiURL(_ endpoint: IMDBendpoint) -> URL {
        endpoint.endpointURL
    }
}

extension URL {
    enum TMDBendpoint {
        case imdbMovieSearch(movieId: String)
        case posterURL(posterPath: String, posterSize: String = "w500")

        var endpointURL: URL {
            let apiBaseUrl = "https://api.themoviedb.org/3"
            let apiKey = "599cd15476ea5d49e4663aee7ba500a0"

            let imagesBaseUrl = "https://image.tmdb.org"

            var urlString: String
            switch self {
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

    static func apiURL(_ endpoint: TMDBendpoint) -> URL {
        endpoint.endpointURL
    }
}
