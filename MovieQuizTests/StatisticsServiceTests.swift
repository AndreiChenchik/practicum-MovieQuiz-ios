import XCTest
@testable import MovieQuiz

final class TestDefaults: UserDefaults {
    // swiftlint:disable:next array_constructor
    private var values = [String: Any]()

    override func object(forKey defaultName: String) -> Any? {
        values[defaultName]
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        values[defaultName] = value
    }
}

final class StatisticsServiceTests: XCTestCase {
    func testGamesCount() {
        // Given
        let sut = StatisticsService(userDefaults: TestDefaults())

        // When
        sut.store(correct: 10, total: 10, date: Date())
        sut.store(correct: 10, total: 10, date: Date())
        sut.store(correct: 10, total: 10, date: Date())

        // Then
        XCTAssertEqual(sut.gamesCount, 3)
    }

    func testTotalAccuracy() {
        // Given
        let sut = StatisticsService(userDefaults: TestDefaults())

        // When
        sut.store(correct: 10, total: 10, date: Date())
        sut.store(correct: 1, total: 14, date: Date())
        sut.store(correct: 5, total: 12, date: Date())

        // Then
        let expectedAcc = (10.0 / 10.0 + 1.0 / 14.0 + 5.0 / 12.0) / 3.0
        XCTAssertEqual(sut.totalAccuracy, expectedAcc)
    }

    func testBestGame() {
        // Given
        let sut = StatisticsService(userDefaults: TestDefaults())

        // When
        sut.store(correct: 9, total: 10, date: .distantFuture)
        sut.store(correct: 1, total: 14, date: Date())
        sut.store(correct: 5, total: 12, date: Date())

        // Then
        XCTAssertEqual(sut.bestGame.correct, 9)
        XCTAssertEqual(sut.bestGame.total, 10)
        XCTAssertEqual(sut.bestGame.date, .distantFuture)
    }
}
