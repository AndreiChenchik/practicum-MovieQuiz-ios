import XCTest
@testable import MovieQuiz

final class DateTests: XCTestCase {
    override func setUp() {
        super.setUp()
        NSTimeZone.default = TimeZone.gmt
    }

    override func tearDown() {
        super.tearDown()
        NSTimeZone.default = NSTimeZone.system
    }

    func testDateFormatter() {
        // Given
        let minutes = 10
        let hours = 21
        let seconds = 31
        let days = 12

        let intervalSec = seconds + 60 * (minutes + 60 * (hours + 24 * days))
        let timeInterval = TimeInterval(intervalSec)

        let date = Date(timeIntervalSince1970: 0) + timeInterval

        // When
        let formattedDate = date.dateTimeString

        // Then
        XCTAssertEqual(formattedDate, "\(days + 1).01.70 \(hours):\(minutes)")
    }
}
