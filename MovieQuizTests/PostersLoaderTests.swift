//
//  PostersLoaderTests.swift
//  MovieQuizTests
//
//  Created by Andrei Chenchik on 27/8/22.
//

import XCTest
@testable import MovieQuiz

struct StubPostersNetworkClient: NetworkRouting {
    enum TestError: Error {
        case test
    }

    let emulateError: Bool

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        print(url.absoluteString)
        if emulateError {
            handler(.failure(TestError.test))
        } else if url.absoluteString.contains("testImage.jpg") {
            handler(.success(UIImage.checkmark.pngData() ?? Data()))
        } else {
            handler(.success(expectedResponse))
        }
    }

    private var expectedResponse: Data {
        let json = """
        {
            "movie_results":[
                {
                    "adult":false,
                    "backdrop_path":"/gr4AHiZLNMgKWIvdnd3peqSkNba.jpg",
                    "id":6068,
                    "title":"Six Days Seven Nights",
                    "original_language":"en",
                    "original_title":"Six Days Seven Nights",
                    "overview":"When Quinn, ....",
                    "poster_path":"/testImage.jpg",
                    "media_type":"movie",
                    "genre_ids":[
                        12,
                        28,
                        35,
                        10749
                    ],
                    "popularity":27.308,
                    "release_date":"1998-06-12",
                    "video":false,
                    "vote_average":5.999,
                    "vote_count":1172
                }
            ],
            "person_results":[

            ],
            "tv_results":[

            ],
            "tv_episode_results":[

            ],
            "tv_season_results":[

            ]
        }
        """

        return json.data(using: .utf8) ?? Data()
    }
}

final class PostersLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        // Given
        let stubClient = StubPostersNetworkClient(emulateError: false)
        let loader = PostersLoader(networkClient: stubClient)

        // When
        let expectation = expectation(description: "Loading expectation")

        loader.loadPosterData(movieId: "testMovieId") { result in
            // Then
            switch result {
            case .success(let imageData):
                XCTAssertEqual(imageData, UIImage.checkmark.pngData())
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testFailureLoading() throws {
        // Given
        let stubClient = StubPostersNetworkClient(emulateError: true)
        let loader = PostersLoader(networkClient: stubClient)

        // When
        let expectation = expectation(description: "Failure expectation")

        loader.loadPosterData(movieId: "testMovieId") { result in
            // Then
            switch result {
            case .success:
                XCTFail("Unexpected data")
                expectation.fulfill()
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }
}
