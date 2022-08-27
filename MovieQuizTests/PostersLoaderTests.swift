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
        } else if url.absoluteString == "testImage.jpg" {
            handler(.success(UIImage.checkmark.pngData() ?? Data()))
        } else {
            handler(.success(expectedResponse))
        }
    }

    private var expectedResponse: Data {
        let json = """
        {
            "imDbId":"tt13314558",
            "title":"Day Shift",
            "fullTitle":"Day Shift (2022)",
            "type":"Movie",
            "year":"2022",
            "posters":[
                {
                    "id":"yQNo9KVTyDzx3NXgyCLqnaZ0k0K.jpg",
                    "link":"testImage.jpg",
                    "aspectRatio":0.6666666666666666,
                    "language":"en",
                    "width":2000,
                    "height":3000
                },
                {
                    "id":"bI7lGR5HuYlENlp11brKUAaPHuO.jpg",
                    "link":"testImage.jpg",
                    "aspectRatio":0.6666666666666666,
                    "language":"en",
                    "width":500,
                    "height":750
                }
            ],
            "errorMessage":""
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

        loader.loadRandomPoster(movieId: "testMovieId") { result in
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

        loader.loadRandomPoster(movieId: "testMovieId") { result in
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
