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
        let url = URL.imdbUrl(.moviePostersBase)
            .appendingPathComponent("/\(movieId)")

        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let apiResponse = try JSONDecoder().decode(
                        ApiResponse.self, from: data
                    )

                    if !apiResponse.error.isEmpty {
                        throw ApiError.genericError(message: apiResponse.error)
                    }

                    let moviePosters = try JSONDecoder().decode(
                        MoviePosters.self, from: data
                    )

                    if let randomPoster = moviePosters.posters.randomElement() {
                        do {
                            let imageData = try Data(
                                contentsOf: randomPoster.imageURL
                            )
                            handler(.success(imageData))
                        } catch {
                            handler(.failure(error))
                        }
                    } else {
                        handler(.failure(ParsingError.imageError))
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
