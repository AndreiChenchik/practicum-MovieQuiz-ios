//
//  URLTests.swift
//  MovieQuizTests
//
//  Created by Andrei Chenchik on 27/8/22.
//

import XCTest
@testable import MovieQuiz

final class URLTests: XCTestCase {
    func testAllColorAssets() throws {
        // Given
        let imdbEndpoints = URL.ImdbEndpoint.allCases

        // When
        for endpoint in imdbEndpoints {
            let url = URL.imdbUrl(endpoint)

            // Then
            XCTAssertEqual(url.host ?? "", "imdb-api.com")
            XCTAssertFalse(
                url.isFileURL,
                "IMDB Endpoint \(endpoint.rawValue) can't be FileUrl"
            )
        }
    }
}
