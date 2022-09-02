import XCTest
@testable import MovieQuiz

class StubURLProtocol: URLProtocol {
    typealias MockResponse = (HTTPURLResponse, Data?)
    static var requestHandler: ((URLRequest) throws -> MockResponse)?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = StubURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(
                self, didReceive: response, cacheStoragePolicy: .notAllowed
            )

            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}


// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
final class NetworkClientTests: XCTestCase {
    var urlSession: URLSession!

    override func setUp() {
        super.setUp()
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
    }

    func testSuccessLoad() {
        // Given
        let sut = NetworkClient(urlSession: urlSession)

        let url = URL.apiURL(.mostPopularMovies)
        let urlData = "[]".data(using: .utf8)!
        StubURLProtocol.requestHandler = { _ in
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

        StubURLProtocol.requestHandler = { _ in
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

        StubURLProtocol.requestHandler = { _ in
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
