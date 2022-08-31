//
//  PostersLoader.swift
//  MovieQuiz
//
//  Created by Andrei Chenchik on 18/8/22.
//

import Foundation

struct PostersLoader: PostersLoading {
    private enum ParsingError: Error {
        case imageError
    }

    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting) {
        self.networkClient = networkClient
    }

    private func loadURLData(
        url: URL,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let imageData):
                handler(.success(imageData))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    func loadPosterData(
        movieId: String,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {
        let url = URL.apiURL(.imdbMovieSearch(movieId: movieId))

        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let searchResponse = try JSONDecoder().decode(
                        MovieSearchResult.self, from: data
                    )

                    if let path = searchResponse.movies[safe: 0]?.posterPath {
                        let posterURL = URL.apiURL(.posterURL(posterPath: path))
                        loadURLData(url: posterURL, handler: handler)
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
