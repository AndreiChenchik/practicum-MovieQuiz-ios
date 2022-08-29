//
//  URLTests.swift
//  MovieQuizTests
//
//  Created by Andrei Chenchik on 27/8/22.
//

import XCTest
@testable import MovieQuiz

extension URL.IMDBendpoint: CaseIterable {
    public static var allCases: [URL.IMDBendpoint] = [
        .moviePostersBase,
        .mostPopularMovies
    ]
}

extension URL.TMDBendpoint: CaseIterable {
    public static var allCases: [URL.TMDBendpoint] = [
        .imdbMovieSearch(movieId: "testId"),
        .posterURL(posterPath: "/fakeImage.jpg")
    ]
}

final class URLTests: XCTestCase {
    func testAllIMDBendpoints() throws {
        // Given
        let endpoints = URL.IMDBendpoint.allCases

        // When
        for endpoint in endpoints {
            let url = URL.apiURL(endpoint)

            // Then
            XCTAssertEqual(url.host ?? "", "imdb-api.com")
            XCTAssertFalse(
                url.isFileURL,
                "IMDB endpoint \(endpoint.rawValue) can't be empty"
            )
        }
    }

    func testAllTMDBendpoints() throws {
        // Given
        let endpoints = URL.TMDBendpoint.allCases

        // When
        for endpoint in endpoints {
            let url = URL.apiURL(endpoint)

            // Then
            switch endpoint {
            case .imdbMovieSearch(let movieId):
                XCTAssertTrue(
                    endpoint.endpointURL.absoluteString.contains(movieId),
                    "imdbMovieSearch URL must contain movieId"
                )
                XCTAssertEqual(url.host ?? "", "api.themoviedb.org")
            case let .posterURL(posterPath, _):
                XCTAssertTrue(
                    endpoint.endpointURL.absoluteString.contains(posterPath),
                    "posterURL must contain posterPath"
                )
                XCTAssertEqual(url.host ?? "", "image.tmdb.org")
            }

            XCTAssertFalse(
                url.isFileURL,
                "TMDB endpoint \(endpoint) can't be empty"
            )
        }
    }
}
