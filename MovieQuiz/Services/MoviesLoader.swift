//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 18/8/22.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    )
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()

    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(
            string: "https://imdb-api.com/en/API/MostPopularMovies/k_kiwxbi4y"
        ) else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }

        return url
    }


    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    ) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let apiResponse = try JSONDecoder().decode(
                        ApiResponse.self, from: data
                    )

                    if !apiResponse.error.isEmpty {
                        throw ApiError.genericError(message: apiResponse.error)
                    }

                    let mostPopularMovies = try JSONDecoder().decode(
                        MostPopularMovies.self, from: data
                    )

                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
