import XCTest
@testable import MovieQuiz

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
final class NetworkClientTests: XCTestCase {
    var urlSession: URLSession!

    override func setUp() {
        super.setUp()
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
    }

    func testSuccessLoad() {
        // Given
        let sut = NetworkClient(urlSession: urlSession)

        let url = URL.apiURL(.mostPopularMovies)
        let urlData = "[]".data(using: .utf8)!
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return (response, urlData)
        }

        // When
        let expectation = expectation(description: "Loading expectation")
        sut.fetch(url: url) { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data, urlData)
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testWrongStatusCodeLoad() {
        // Given
        let sut = NetworkClient(urlSession: urlSession)
        let url = URL.apiURL(.mostPopularMovies)

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: url,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!

            return (response, nil)
        }

        // When
        let expectation = expectation(description: "Failure expectation")
        sut.fetch(url: url) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure:
                expectation.fulfill()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testErrorLoad() {
        // Given
        let sut = NetworkClient(urlSession: urlSession)
        let url = URL.apiURL(.mostPopularMovies)
        let error = NSError(domain: "test", code: 100)

        MockURLProtocol.requestHandler = { _ in
            throw error
        }

        // When
        let expectation = expectation(description: "Failure expectation")
        sut.fetch(url: url) { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure:
                expectation.fulfill()
            }
        }

        // Then
        wait(for: [expectation], timeout: 1)
    }
}
