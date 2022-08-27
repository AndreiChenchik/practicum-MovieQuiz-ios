//
//  PostersLoader.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 18/8/22.
//

import Foundation

protocol PostersLoading {
    func loadRandomPoster(
        movieId: String,
        handler: @escaping (Result<Data, Error>) -> Void
    )
}

struct PostersLoader: PostersLoading {
    private enum ParsingError: Error {
        case imageError
    }

    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting) {
        self.networkClient = networkClient
    }

    func loadRandomPoster(
        movieId: String,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {
        let url = URL.tmdbUrl(.imdbMovieSearch(movieId: movieId))

        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let searchResponse = try JSONDecoder().decode(
                        MovieSearchResponse.self, from: data
                    )

                    if let path = searchResponse.movies[safe: 0]?.posterPath {
                        networkClient.fetch(
                            url: .tmdbUrl(.posterURL(posterPath: path))
                        ) { result in
                            switch result {
                            case .success(let imageData):
                                handler(.success(imageData))
                            case .failure(let error):
                                handler(.failure(error))
                            }
                        }
                    } else {
                        let message = "TMDB have no info about '\(movieId)' id"
                        throw ApiError.genericError(message: message)
                    }
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
