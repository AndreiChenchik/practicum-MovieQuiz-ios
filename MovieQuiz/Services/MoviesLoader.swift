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
    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting) {
        self.networkClient = networkClient
    }

    func loadMovies(
        handler: @escaping (Result<MostPopularMovies, Error>) -> Void
    ) {
        networkClient.fetch(url: .imdbUrl(.mostPopularMovies)) { result in
            switch result {
            case .success(let data):
                do {
                    let apiResponse = try JSONDecoder().decode(
                        IMDBApiResponse.self, from: data
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
