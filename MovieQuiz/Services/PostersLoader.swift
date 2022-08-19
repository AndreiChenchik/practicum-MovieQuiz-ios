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

    // MARK: - NetworkClient
    private let networkClient = NetworkClient()

    // MARK: - URL
    private var moviePostersBaseUrl: URL {
        guard let url = URL(
            string: "https://imdb-api.com/en/API/Posters/k_kiwxbi4y"
        ) else {
            preconditionFailure("Unable to construct moviePostersUrl")
        }

        return url
    }


    func loadRandomPoster(
        movieId: String,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {
        let url = moviePostersBaseUrl.appendingPathComponent("/\(movieId)")

        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let apiResponse = try JSONDecoder().decode(
                        ApiResponse.self, from: data
                    )

                    if !apiResponse.error.isEmpty {
                        handler(
                            .failure(ApiError.genericError(apiResponse.error))
                        )
                        return
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
